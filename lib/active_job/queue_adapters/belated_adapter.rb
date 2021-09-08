# frozen_string_literal: true

require 'belated'

module ActiveJob # :nodoc:
  module QueueAdapters # :nodoc:
    # The adapter in charge of handling ActiveJob integration.
    # WIP
    class BelatedAdapter
      def instance
        @instance ||= Belated::Client.instance
      rescue StandardError
        @instance = Belated::Client.new
      end

      def enqueue(job) # :nodoc:
        Rails.logger.info "Belated got job #{job}"
        instance.perform(job, active_job: true)
      end

      def enqueue_at(job, timestamp) # :nodoc:
        Rails.logger.info "Belated got job #{job} to be performed at #{Time.at(timestamp)}"
        instance.perform_belated(job, at: timestamp, active_job: true)
      end

      # JobWrapper that overwrites perform for ActiveJob
      class JobWrapper < Belated::JobWrapper
        def perform
          Base.execute job.serialize
        end
      end
    end
  end
end
