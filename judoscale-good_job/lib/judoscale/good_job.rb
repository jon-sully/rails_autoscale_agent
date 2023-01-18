# frozen_string_literal: true

# require "good_job" fails unless we require these first
require "rails"
require "active_support/core_ext/numeric/time"
require "active_job/railtie"
require "good_job"
require "judoscale-ruby"
require "judoscale/config"
require "judoscale/good_job/version"
require "judoscale/good_job/metrics_collector"

Judoscale.add_adapter :"judoscale-good_job",
  {
    adapter_version: Judoscale::GoodJob::VERSION,
    framework_version: ::GoodJob::VERSION
  },
  metrics_collector: Judoscale::GoodJob::MetricsCollector,
  expose_config: Judoscale::Config::JobAdapterConfig.new(:good_job)
