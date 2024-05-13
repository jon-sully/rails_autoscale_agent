# frozen_string_literal: true

require "judoscale-ruby"
require "judoscale/config"
require "judoscale/version"
require "judoscale/que/metrics_collector"
require "que"

Judoscale.add_adapter :"judoscale-que",
  {
    adapter_version: Judoscale::VERSION,
    framework_version: ::Que::VERSION
  },
  metrics_collector: Judoscale::Que::MetricsCollector,
  expose_config: Judoscale::Config::JobAdapterConfig.new(:que)
