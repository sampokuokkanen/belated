require_relative 'logging'
require 'pstore'

class Belated
  # The worker class that actually gets the jobs from the queue
  # and calls them. Expects the jobs to be procs or
  # classes that have a perform method.
  class Worker
    include Logging

    def initialize(number: 1)
      @number = number
      start_working
    end

    def start_working
      loop do
        log "Worker #{@number} fetching jobs!"
        next unless (job = Belated.fetch_job)

        break if job.is_a?(Symbol)

        log "Worker #{@number} got job: #{job.inspect}"
        log job.perform
        history_insert(job) unless job.proc_klass || !job.completed
      rescue DRb::DRbConnError, Errno::ECONNREFUSED, RangeError => e
        log e
      end
    end

    private

    def history_insert(job)
      store.transaction do
        store[job.id] = job
      end
    rescue StandardError => e
      error e
    end

    def store
      today = Time.now.strftime('%F')
      return @store if @store&.path&.include?(today)

      @store = PStore.new("history-#{today}.pstore", true)
    end
  end
end
