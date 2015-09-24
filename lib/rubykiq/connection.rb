require 'redis'
require 'redis/namespace'

module Rubykiq
  class Connection
    extend Forwardable
    def_delegators :@redis_connection, :multi, :namespace, :sadd, :zadd, :lpush, :lpop, :lrange, :llen, :zcard, :zrange, :flushdb
    def_delegators :@redis_client, :host, :port, :db, :password

    # Initialize a new Connection object
    #
    # @param options [Hash]
    def initialize(options = {})
      options[:url] ||= determine_redis_provider
      namespace = options.delete(:namespace)
      @redis_connection = initialize_conection(options, namespace)
      @redis_client = @redis_connection.client
      @redis_connection
    end

    private

    def determine_redis_provider
      # lets try and fallback to another redis url
      ENV['REDISTOGO_URL'] || ENV['REDIS_PROVIDER'] || ENV['REDIS_URL'] || 'redis://localhost:6379/0'
    end

    def initialize_conection(options, namespace)
      client = ::Redis.new(options)
      ::Redis::Namespace.new(namespace, redis: client)
    end
  end
end
