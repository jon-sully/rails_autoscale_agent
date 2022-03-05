# frozen_string_literal: true

module Judoscale
  # Allows configuring Judoscale through a block, usually defined during application initialization.
  #
  # Example:
  #
  #    Judoscale.configure do |config|
  #      config.logger = MyLogger.new
  #    end
  def self.configure
    yield Config.instance
  end

  @adapters = []
  class << self
    attr_reader :adapters
  end

  Adapter = Struct.new(:identifier, :adapter_info) do
    def as_json
      {identifier => adapter_info}
    end
  end

  def self.add_adapter(identifier, adapter_info)
    @adapters << Adapter.new(identifier, adapter_info)
  end

  add_adapter :"judoscale-ruby", {
    adapter_version: VERSION,
    language_version: RUBY_VERSION
  }
end

require "judoscale/config"
require "judoscale/version"
