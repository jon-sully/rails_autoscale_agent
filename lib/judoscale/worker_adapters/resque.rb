# frozen_string_literal: true

require "judoscale/worker_adapters/base"

module Judoscale
  module WorkerAdapters
    class Resque < Base
      def enabled?
        require "resque"
        logger.info "Resque enabled"
        true
      rescue LoadError
        false
      end

      def collect!(store)
        log_msg = +""
        current_queues = ::Resque.queues

        return if number_of_queues_to_collect_exceeded_limit?(current_queues)

        # Ensure we continue to collect metrics for known queue names, even when nothing is
        # enqueued at the time. Without this, it will appears that the agent is no longer reporting.
        self.queues |= current_queues

        queues.each do |queue|
          next if queue.nil? || queue.empty?
          depth = ::Resque.size(queue)
          store.push :qd, depth, Time.now, queue
          log_msg << "resque-qd.#{queue}=#{depth} "
        end

        logger.debug log_msg
      end
    end
  end
end
