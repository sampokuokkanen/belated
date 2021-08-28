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
        instance.perform(job)
      end

      def enqueue_at(job, timestamp) # :nodoc:
        Rails.logger.info "Belated got job #{job} to be performed at #{Time.at(timestamp)}"
        instance.perform_belated(job, at: timestamp)
      end

      class JobWrapper < Belated::JobWrapper # :nodoc:
        def self.perform(job)
          Base.execute job
        end
      end
    end
  end
end
