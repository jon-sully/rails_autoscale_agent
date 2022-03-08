# frozen_string_literal: true

require "judoscale-ruby"
require "judoscale/sidekiq/version"
require "judoscale/sidekiq/config"
require "judoscale/sidekiq/metrics_collector"
require "sidekiq/api"

Judoscale.add_adapter :"judoscale-sidekiq", {
  adapter_version: Judoscale::Sidekiq::VERSION,
  framework_version: ::Sidekiq::VERSION
}, metrics_collector: Judoscale::Sidekiq::MetricsCollector
