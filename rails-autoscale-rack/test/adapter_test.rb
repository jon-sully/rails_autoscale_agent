# frozen_string_literal: true

require "test_helper"
require "judoscale/report"

module Judoscale
  describe Rack do
    it "adds itself as an adapter with information to be reported to the Rails Autoscale API" do
      adapter = Judoscale.adapters.detect { |adapter| adapter.identifier == :"rails-autoscale-rack" }
      _(adapter).wont_be_nil
      _(adapter.metrics_collector).must_equal Judoscale::WebMetricsCollector

      report = ::Judoscale::Report.new(Judoscale.adapters, Judoscale::Config.instance, [])
      _(report.as_json[:adapters]).must_include(:"rails-autoscale-rack")
    end
  end
end
