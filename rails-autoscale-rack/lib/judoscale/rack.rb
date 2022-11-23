# frozen_string_literal: true

require "rails-autoscale-core"
require "judoscale/rack/version"
require "judoscale/web_metrics_collector"
require "judoscale/request_middleware"
require "rack"

# For Rack apps, Judoscale::RequestMiddleware must be manually inserted into
# the app's middleware chain.

Judoscale.add_adapter :"rails-autoscale-rack", {
  adapter_version: Judoscale::Rack::VERSION,
  framework_version: ::Rack.version
}, metrics_collector: Judoscale::WebMetricsCollector
