require "forwardable"
require "rubykiq/client"
require "rubykiq/connection"

module Rubykiq
  extend SingleForwardable

  def_delegators :client, :<<, :push, :connection_pool

  # delegate all VALID_OPTIONS_KEYS accessors to the client
  def_delegators :client, *Rubykiq::Client::VALID_OPTIONS_KEYS

  # delegate all VALID_OPTIONS_KEYS setters to the client ( Hacky I know... )
  def_delegators :client, *(Rubykiq::Client::VALID_OPTIONS_KEYS.dup.collect! do |key| "#{key}=".to_sym; end)

  # Fetch the Rubykiq::Client
  #
  # @return [Rubykiq::Client]
  def self.client(options={})
    @client ||= Rubykiq::Client.new(options)
  end

end