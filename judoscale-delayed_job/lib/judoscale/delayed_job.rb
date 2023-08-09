# frozen_string_literal: true

require "judoscale-ruby"
require "judoscale/config"
require "judoscale/delayed_job/version"
require "judoscale/delayed_job/metrics_collector"
require "delayed_job_active_record"

Judoscale::Config.instance.allow_rake_tasks << /jobs:work/

Judoscale.add_adapter :"judoscale-delayed_job",
  {
    adapter_version: Judoscale::DelayedJob::VERSION,
    framework_version: Gem.loaded_specs["delayed_job_active_record"].version.to_s # DJ doesn't have a `VERSION` constant
  },
  metrics_collector: Judoscale::DelayedJob::MetricsCollector,
  expose_config: Judoscale::Config::JobAdapterConfig.new(:delayed_job)
