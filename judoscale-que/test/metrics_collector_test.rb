# frozen_string_literal: true

require "test_helper"
require "judoscale/que/metrics_collector"
require "securerandom"

module Judoscale
  describe Que::MetricsCollector do
    def enqueue(queue, run_at)
      ActiveRecord::Base.connection.insert <<~SQL
        INSERT INTO que_jobs (job_class, job_schema_version, queue, run_at)
        VALUES ('TestJob', 1, '#{queue}', '#{run_at.utc.iso8601(6)}')
      SQL
    end

    def clear_enqueued_jobs
      ActiveRecord::Base.connection.execute("DELETE FROM que_jobs")
    end

    def lock_enqueued_jobs(*enqueued_job_ids)
      enqueued_job_ids.each do |job_id|
        ActiveRecord::Base.connection.execute("SELECT pg_advisory_lock(#{job_id})")
      end

      yield
    ensure
      enqueued_job_ids.each do |job_id|
        ActiveRecord::Base.connection.execute("SELECT pg_advisory_unlock(#{job_id})")
      end
    end

    subject { Que::MetricsCollector.new }

    describe "#collect" do
      after {
        clear_enqueued_jobs
        subject.clear_queues
      }

      it "collects latency for each queue" do
        metrics = freeze_time do
          enqueue("default", Time.now - 11)
          enqueue("high", Time.now - 22.2222)

          subject.collect
        end

        _(metrics.size).must_equal 2
        _(metrics[0].queue_name).must_equal "default"
        _(metrics[0].value).must_be_within_delta 11000, 1
        _(metrics[0].identifier).must_equal :qt
        _(metrics[1].queue_name).must_equal "high"
        _(metrics[1].value).must_be_within_delta 22222, 1
        _(metrics[1].identifier).must_equal :qt
      end

      it "always collects for known queues" do
        metrics = subject.collect

        _(metrics).must_be :empty?

        enqueue("default", Time.now)
        metrics = subject.collect

        _(metrics.size).must_equal 1
        _(metrics[0].queue_name).must_equal "default"

        clear_enqueued_jobs
        metrics = subject.collect

        _(metrics.size).must_equal 1
        _(metrics[0].queue_name).must_equal "default"
      end

      it "skips collecting metrics for jobs locked for execution" do
        que_job_id = enqueue("default", Time.now)

        metrics = lock_enqueued_jobs(que_job_id) do
          subject.collect
        end

        _(metrics).must_be :empty?

        metrics = subject.collect

        _(metrics.size).must_equal 1
        _(metrics[0].queue_name).must_equal "default"
      end

      it "logs debug information for each queue being collected" do
        use_config log_level: :debug do
          enqueue("default", Time.now)

          subject.collect

          _(log_string).must_match %r{que-qt.default=\d+ms}
          _(log_string).wont_match %r{que-busy.default}
        end
      end

      it "tracks busy jobs when the configuration is enabled" do
        use_adapter_config :que, track_busy_jobs: true do
          que_job_ids = [
            enqueue("default", Time.now),
            enqueue("default", Time.now),
            enqueue("high", Time.now)
          ]

          metrics = lock_enqueued_jobs(*que_job_ids) do
            subject.collect
          end

          _(metrics.size).must_equal 4
          _(metrics[1].value).must_equal 2
          _(metrics[1].queue_name).must_equal "default"
          _(metrics[1].identifier).must_equal :busy
          _(metrics[3].value).must_equal 1
          _(metrics[3].queue_name).must_equal "high"
          _(metrics[3].identifier).must_equal :busy
        end
      end

      it "logs debug information about busy jobs being collected" do
        use_config log_level: :debug do
          use_adapter_config :que, track_busy_jobs: true do
            que_job_id = enqueue("default", Time.now)

            lock_enqueued_jobs(que_job_id) do
              subject.collect
            end

            _(log_string).must_match %r{que-qt.default=0ms que-busy.default=1}
          end
        end
      end

      it "filters queues matching UUID format by default, to prevent reporting for dynamically generated queues" do
        %W[low-#{SecureRandom.uuid} default #{SecureRandom.uuid}-high].each { |queue| enqueue(queue, Time.now) }

        metrics = subject.collect

        _(metrics.size).must_equal 1
        _(metrics[0].queue_name).must_equal "default"
      end

      it "filters queues to collect metrics from based on the configured queue filter proc, overriding the default UUID filter" do
        use_adapter_config :que, queue_filter: ->(queue_name) { queue_name.start_with? "low" } do
          %W[low default high low-#{SecureRandom.uuid}].each { |queue| enqueue(queue, Time.now) }

          metrics = subject.collect

          _(metrics.size).must_equal 2
          _(metrics[0].queue_name).must_equal "low"
          _(metrics[1].queue_name).must_be :start_with?, "low-"
        end
      end

      it "collects metrics only from the configured queues if the configuration is present, ignoring the queue filter" do
        use_adapter_config :que, queues: %w[low ultra], queue_filter: ->(queue_name) { queue_name != "low" } do
          %w[low default high].each { |queue| enqueue(queue, Time.now) }

          metrics = subject.collect

          _(metrics.map(&:queue_name)).must_equal %w[low ultra]
        end
      end

      it "collects metrics up to the configured number of max queues, sorting by length of the queue name" do
        use_adapter_config :que, max_queues: 2 do
          %w[low default high].each { |queue| enqueue(queue, Time.now) }

          metrics = subject.collect

          _(metrics.map(&:queue_name)).must_equal %w[low high]
          _(log_string).must_match %r{Que metrics reporting only 2 queues max, skipping the rest \(1\)}
        end
      end
    end
  end
end
