module Rubykiq

  class Client

    # An array of valid keys in the options hash when configuring an {Rubykiq::Client}
    VALID_OPTIONS_KEYS = [
      :namespace,
      :driver
    ].freeze

    # A hash of valid options and their default value's
    DEFAULT_OPTIONS = {
      :namespace => nil,
      :driver => :ruby
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
      @connection ||= Rubykiq::Connection.new(options)
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
    #   Sidekiq::Client.push('queue' => 'my_queue', 'class' => MyWorker, 'args' => ['foo', 1, :bat => 'bar'])
    #
    def push
      # normed = normalize_item(item)
      # payload = process_single(item['class'], normed)

      # pushed = false
      # pushed = raw_push([payload]) if payload
      # pushed ? payload['jid'] : nil
    end

    private

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