# frozen_string_literal: true

require "rails"
require "rails/railtie"
require "judoscale/request_middleware"
require "judoscale/config"
require "judoscale/logger"
require "judoscale/reporter"

module Judoscale
  module Web
    class Railtie < ::Rails::Railtie
      include Judoscale::Logger

      initializer "Judoscale.logger" do |app|
        Config.instance.logger = ::Rails.logger
      end

      initializer "Judoscale.request_middleware" do |app|
        logger.info "Preparing request middleware"
        app.middleware.insert_before Rack::Runtime, RequestMiddleware
      end

      config.after_initialize do
        Reporter.start
      end
    end
  end
end
