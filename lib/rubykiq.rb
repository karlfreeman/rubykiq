require 'thread'
require 'forwardable'
require 'rubykiq/client'
require 'rubykiq/connection'

module Rubykiq
  extend SingleForwardable

  def_delegators :client, :<<, :push, :connection_pool, :connection_pool=

  # delegate all VALID_OPTIONS_KEYS accessors to the client
  def_delegators :client, *Rubykiq::Client::VALID_OPTIONS_KEYS

  # delegate all VALID_OPTIONS_KEYS setters to the client ( hacky I know... )
  def_delegators :client, *(Rubykiq::Client::VALID_OPTIONS_KEYS.dup.map! do |key| "#{key}=".to_sym; end)

  # Fetch the Rubykiq::Client
  #
  # @return [Rubykiq::Client]
  def self.client(options = {})
    initialize_client(options) unless defined?(@client)
    @client
  end

  private

  def self.initialize_client(options = {})
    Thread.exclusive do
      @client = Rubykiq::Client.new(options)
    end
  end
end
