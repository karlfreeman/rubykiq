require 'connection_pool'
require 'securerandom'
require 'multi_json'
require 'time'

module Rubykiq
  class Client
    # An array of valid keys in the options hash when configuring a `Rubykiq::Client`
    VALID_OPTIONS_KEYS = [
      :redis_pool_size,
      :redis_pool_timeout,
      :url,
      :namespace,
      :driver,
      :retry,
      :queue
    ].freeze

    # A hash of valid options and their default values
    DEFAULT_OPTIONS = {
      redis_pool_size: 1,
      redis_pool_timeout: 1,
      url: nil,
      namespace: nil,
      driver: :ruby,
      retry: true,
      queue: 'default'
    }.freeze

    # Bang open the valid options
    attr_accessor(*VALID_OPTIONS_KEYS)

    # allow the connection_pool to be set
    attr_writer :connection_pool

    # Initialize a new Client object
    #
    # @param options [Hash]
    def initialize(options = {})
      reset_options
      options.each_pair do |key, value|
        send("#{key}=", value) if VALID_OPTIONS_KEYS.include?(key)
      end
    end

    # Fetch the ::ConnectionPool of Rubykiq::Connections
    #
    # @return [::ConnectionPool]
    def connection_pool(options = {}, &block)
      options = valid_options.merge(options)

      @connection_pool ||= ::ConnectionPool.new(timeout: redis_pool_timeout, size: redis_pool_size) do
        Rubykiq::Connection.new(options)
      end

      if block_given?
        @connection_pool.with(&block)
      else
        return @connection_pool
      end
    end

    # Push a Sidekiq job to Redis. Accepts a number of options:
    #
    #   :class - the worker class to call, required.
    #   :queue - the named queue to use, optional ( default: 'default' )
    #   :args - an array of simple arguments to the perform method, must be JSON-serializable, optional ( default: [] )
    #   :retry - whether to retry this job if it fails, true or false, default true, optional ( default: true )
    #   :at - when the job should be executed. This can be a `Time`, `Date` or any `Time.parse`-able strings, optional.
    #
    # Returns nil if not pushed to Redis. In the case of an indvidual job a job ID will be returned,
    # if multiple jobs are pushed the size of the jobs will be returned
    #
    # Example:
    #   Rubykiq.push(:class => 'Worker', :args => ['foo', 1, :bat => 'bar'])
    #   Rubykiq.push(:class => 'Scheduler', :queue => 'scheduler')
    #   Rubykiq.push(:class => 'DelayedMailer', :at => '2013-01-01T09:00:00Z')
    #   Rubykiq.push(:class => 'Worker', :args => [['foo'], ['bar']])
    #
    # @param items [Array]
    def push(items)
      fail(ArgumentError, 'Message must be a Hash') unless items.is_a?(Hash)
      fail(ArgumentError, 'Message args must be an Array') if items[:args] && !items[:args].is_a?(Array)

      # args are optional
      items[:args] ||= []

      # determine if this items arg's is a nested array
      items[:args].first.is_a?(Array) ? push_many(items) : push_one(items)
    end
    alias_method :<<, :push

    private

    # Create a hash of options and their values
    def valid_options
      VALID_OPTIONS_KEYS.reduce({}) { |a, e| a.merge!(e => send(e)) }
    end

    # Create a hash of the default options and their values
    def default_options
      DEFAULT_OPTIONS
    end

    # Set the VALID_OPTIONS_KEYS with their DEFAULT_OPTIONS
    def reset_options
      VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", default_options[key])
      end
    end

    # when only one item is needed to persisted to redis
    def push_one(item)
      # we're expecting item to be a single item so simply normalize it
      payload = normalize_item(item)

      # if successfully persisted to redis return this item's `jid`
      pushed = false
      pushed = raw_push([payload]) if payload
      pushed ? payload[:jid] : nil
    end

    # when multiple item's are needing to be persisted to redis
    def push_many(items)
      # we're expecting items to have an nested array of args, lets take each one and correctly normalize them
      payloads = items[:args].map do |args|
        fail ArgumentError, "Bulk arguments must be an Array of Arrays: [[:foo => 'bar'], [:foo => 'foo']]" unless args.is_a?(Array)
        # clone the original items (for :queue, :class, etc..)
        item = items.clone
        # merge this item's args (eg the nested `arg` array)
        item.merge!(args: args) unless args.empty?
        # normalize this individual item
        normalize_item(item)
      end.compact

      # if successfully persisted to redis return the size of the jobs
      pushed = false
      pushed = raw_push(payloads) unless payloads.empty?
      pushed ? payloads.size : nil
    end

    # persist the job message(s)
    def raw_push(payloads)
      pushed = false
      connection_pool do |connection|
        if payloads.first[:at]
          pushed = connection.zadd('schedule', payloads.map { |item| [item[:at].to_s, ::MultiJson.encode(item)] })
        else
          q = payloads.first[:queue]
          to_push = payloads.map { |item| ::MultiJson.encode(item) }
          _, pushed = connection.multi do
            connection.sadd('queues', q)
            connection.lpush("queue:#{q}", to_push)
          end
        end
      end
      pushed
    end

    def normalize_item(item)
      fail(ArgumentError, 'Message must be a Hash') unless item.is_a?(Hash)
      fail(ArgumentError, "Message must include a class and set of arguments: #{item.inspect}") if !item[:class] || !item[:args]
      fail(ArgumentError, 'Message args must be an Array') if item[:args] && !item[:args].is_a?(Array)
      fail(ArgumentError, 'Message class must be a String representation of the class name') unless item[:class].is_a?(String)

      # normalize the time
      item[:at] = normalize_time(item[:at]) if item[:at]
      pre_normalized_item = item.clone

      # args are optional
      pre_normalized_item[:args] ||= []

      # apply the default options
      [:retry, :queue].each do |key|
        pre_normalized_item[key] = send("#{key}") unless pre_normalized_item.key?(key)
      end

      # provide a job ID
      pre_normalized_item[:jid] = ::SecureRandom.hex(12)

      pre_normalized_item
    end

    # Given an object meant to represent time, try to convert it intelligently to a float
    def normalize_time(time)
      # if the time param is a `Date` / `String` convert it to a `Time` object
      if time.is_a?(Date)
        normalized_time = time.to_time
      elsif time.is_a?(String)
        normalized_time = Time.parse(time)
      else
        normalized_time = time
      end

      # convert the `Time` object to a float (if necessary)
      normalized_time = normalized_time.to_f unless normalized_time.is_a?(Numeric)

      normalized_time
    end
  end
end
