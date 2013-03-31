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
        send("#{key}=", options[key])
      end
    end

    # Fetch the Rubykiq::Connection
    #
    # @return [Rubykiq::Connection]
    def connection(options={})
      options = default_options.merge(valid_options).merge(options)
      @connection ||= Rubykiq::Connection.new(options)
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