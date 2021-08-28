# frozen_string_literal: true
require 'belated'

module ActiveJob # :nodoc:
  module QueueAdapters # :nodoc:
    # The adapter in charge of handling ActiveJob integration.
    # WIP
    class BelatedAdapter
      def instance
        @instance ||= Belated::Client.new
      end

      def enqueue(job) # :nodoc:
        instance.perform(job)
      end

      def enqueue_at(job, timestamp) # :nodoc:
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
