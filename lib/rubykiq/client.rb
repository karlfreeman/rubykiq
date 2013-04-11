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

    ##
    # The main method used to push a job to Redis.  Accepts a number of options:
    #
    #   queue - the named queue to use, default 'default'
    #   class - the worker class to call, required
    #   args - an array of simple arguments to the perform method, must be JSON-serializable
    #   retry - whether to retry this job if it fails, true or false, default true
    #   backtrace - whether to save any error backtrace, default false
    #
    # All options must be strings, not symbols.  NB: because we are serializing to JSON, all
    # symbols in 'args' will be converted to strings.
    #
    # Returns nil if not pushed to Redis or a unique Job ID if pushed.
    #
    # Example:
    #   Rubykiq::Client.push(:queue => 'my_queue', :class => "MyWorker", :args => ['foo', 1, :bat => 'bar'])
    #   Rubykiq::Client.push(:queue => 'my_queue', :class => "MyWorker", :args => ['foo', 1, :bat => 'bar'])
    #
    def push(item)
      item = normalize_item!(item)
      # normed = normalize_item(item)
      # payload = process_single(item['class'], normed)

      # pushed = false
      # pushed = raw_push([payload]) if payload
      # pushed ? item[:jid] : nil
    end
    alias_method :<<, :push

    private

    #
    def normalize_item!(item)
      raise(ArgumentError, "Message must be a Hash of the form: { :class => SomeWorker, :args => ['bob', 1, :foo => 'bar'] }") unless item.is_a?(Hash)
      raise(ArgumentError, "Message must include a class and set of arguments: #{item.inspect}") if !item[:class] || !item[:args]
      raise(ArgumentError, "Message args must be an Array") unless item[:args].is_a?(Array)
      raise(ArgumentError, "Message class must be a String representation of the class name") unless item[:class].is_a?(String)

      # apply the default options
      [:retry, :queue].each do |key|
        item[key] = send("#{key}")
      end

      # include a job ID
      item[:jid] = SecureRandom.hex(12)

      return item

    end

    #
    def raw_push(payloads)
      pushed = false
      # Rubykiq.redis do |conn|
      #   if payloads.first['at']
      #     pushed = conn.zadd('schedule', payloads.map {|hash| [hash['at'].to_s, Sidekiq.dump_json(hash)]})
      #   else
      #     q = payloads.first['queue']
      #     to_push = payloads.map { |entry| Sidekiq.dump_json(entry) }
      #     _, pushed = conn.multi do
      #       conn.sadd('queues', q)
      #       conn.lpush("queue:#{q}", to_push)
      #     end
      #   end
      # end
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