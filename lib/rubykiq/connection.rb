require 'redis'
require 'redis/namespace'

module Rubykiq

  class Connection

    extend Forwardable
    def_delegator :@connection, :namespace

    # Initialize a new Connection object
    #
    # @param options [Hash]
    def initialize(options = {})
      url = options.delete(:url) { determine_redis_provider }
      namespace = options.delete(:namespace)
      driver = options.delete(:driver) { :ruby }
      @connection = build_conection(url, namespace, driver)
      return @connection
    end

    private

    # lets try and fallback to another redis url
    def determine_redis_provider
      ENV["REDISTOGO_URL"] || ENV["REDIS_PROVIDER"] || ENV["REDIS_URL"] || "redis://localhost:6379/0"
    end

    #
    def build_conection(url, namespace, driver)
      client = ::Redis.connect(:url => url, :driver => driver)
      return ::Redis::Namespace.new(namespace, :redis => client)
    end

  end
end