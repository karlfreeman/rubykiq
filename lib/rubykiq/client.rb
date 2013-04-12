require 'securerandom'

module Rubykiq

  class Client

    # An array of valid keys in the options hash when configuring an {Rubykiq::Client}
    VALID_OPTIONS_KEYS = [
      :namespace,
      :driver,
      :retry,
      :queue
    ].freeze

    # A hash of valid options and their default value's
    DEFAULT_OPTIONS = {
      :namespace => nil,
      :driver => :ruby,
      :retry => true,
      :queue => "default"
    }.freeze

    # Bang open the valid options
    attr_accessor(*VALID_OPTIONS_KEYS)

    # Initialize a new Client object
    #
    # @param options [Hash]
    def initialize(options = {})
      VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", default_options[key])
      end
    end

    # Fetch the Rubykiq::Connection
    #
    # @return [Rubykiq::Connection]
    def connection(options={})
      options = default_options.merge(valid_options).merge(options)
      Rubykiq::Connection.new(options)
    end

    #
    def push(items)
      raise(ArgumentError, "Message must be a Hash") unless items.is_a?(Hash)
      raise(ArgumentError, "Message args must be an Array") if items[:args] && !items[:args].is_a?(Array)

      # args are optional
      items[:args] ||= []

      # determine if this items args is an array of arrays
      items[:args].first.is_a?(Array) ? push_many(items) : push_one(items)

    end
    alias_method :<<, :push


    private

    #
    def push_one(item)

      # we're expecting item to be a single item so simply normalize it
      payload = normalize_item(item)

      #
      pushed = false
      pushed = raw_push([payload]) if payload
      pushed ? payload[:jid] : nil

    end

    #
    def push_many(items)

      # we're expecting items to have an nested array of args, lets take each one and correctly normalize them
      payloads = items[:args].map do |args|
        raise ArgumentError, "Bulk arguments must be an Array of Arrays: [[:foo => 'bar'], [:foo => 'foo']]" unless args.is_a?(Array)
        # clone the original items ( for :queue, :class, etc.. )
        item = items.clone
        # then merge this items args ( eg the nested arg array )
        item.merge!(:args => args) unless args.empty?
        # then normalize the item
        item = normalize_item(item)
      end.compact

      #
      pushed = false
      pushed = raw_push(payloads) unless payloads.empty?
      pushed ? payloads.size : nil

    end

    #
    def normalize_item(item)
      raise(ArgumentError, "Message must be a Hash") unless item.is_a?(Hash)
      raise(ArgumentError, "Message must include a class and set of arguments: #{item.inspect}") if !item[:class] || !item[:args]
      raise(ArgumentError, "Message args must be an Array") if item[:args] && !item[:args].is_a?(Array)
      raise(ArgumentError, "Message class must be a String representation of the class name") unless item[:class].is_a?(String)

      # copy the item
      pre_normalized_item = item.clone

      # args are optional
      pre_normalized_item[:args] ||= []

      # apply the default options
      [:retry, :queue].each do |key|
        pre_normalized_item[key] = send("#{key}")
      end

      # provide a job ID
      pre_normalized_item[:jid] = SecureRandom.hex(12)

      return pre_normalized_item

    end

    #
    def raw_push(payloads)
      # ap payloads
      pushed = false
      if payloads.first[:at]
        pushed = Rubykiq.connection.zadd("schedule", payloads.map {|hash| [ hash[:at].to_s, MultiJson.encode(hash) ]})
      else
        q = payloads.first[:queue]
        to_push = payloads.map { |item| MultiJson.encode(item) }
        _, pushed = Rubykiq.connection.multi do
          Rubykiq.connection.sadd("queues", q)
          Rubykiq.connection.lpush("queue:#{q}", to_push)
        end
      end
      pushed
    end

    # Create a hash of options and their values
    def valid_options
      VALID_OPTIONS_KEYS.inject({}){|o,k| o.merge!(k => send(k)) }
    end

    # Create a hash of the default options and their values
    def default_options
      DEFAULT_OPTIONS
    end

    # Set the VALID_OPTIONS_KEYS with their DEFAULT_OPTIONS
    def reset_options
      VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", DEFAULT_OPTIONS[key])
      end
    end

  end

end