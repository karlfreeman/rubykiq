require "forwardable"
require "rubykiq/client"
require "rubykiq/connection"

module Rubykiq
  extend SingleForwardable

  def_delegators :client, :connection_pool, :reset

  # Fetch the Rubykiq::Client
  #
  # @return [Rubykiq::Client]
  def self.client(options={})
    @client ||= Rubykiq::Client.new(options)
  end

end