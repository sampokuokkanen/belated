require 'belated/job_wrapper'
class Belated
  # The client class is responsible for managing the connection to the
  # DRb server. If it has no connection, it adds the jobs to a bank queue.
  # You can enqueue jobs to be processed by the server.
  # Example:
  #   client = Belated::Client.new
  #   client.enqueue(JubJub.new, at: Time.now + 5.seconds)
  class Client
    attr_accessor :queue, :bank, :banker_thread, :table

    # Starts up the client.
    # Connects to the queue through DRb.
    # @return [void]
    def initialize
      server_uri = Belated::URI
      DRb.start_service
      self.table = {}
      self.bank = Thread::Queue.new
      self.queue = DRbObject.new_with_uri(server_uri)
      start_banker_thread
    end

    # Thread in charge of handling the bank queue.
    # You probably want to memoize the client in order to avoid
    # having many threads in the sleep state.
    # @return [void]
    def start_banker_thread
      self.banker_thread = Thread.new do
        loop do
          sleep 0.01

          unless table.empty?
            table.select { |k, v| v.completed }.each do |key, value|
              table.delete(key)
            end
          end

          if bank.empty?
            sleep 10
          else
            perform(bank.pop)
          end
        end
      end
    end

    # The method that pushes the jobs to the queue.
    # If there is no connection, it pushes the job to the bank.
    # @param job [Object] - The the job to be pushed.
    # @param at [Date] - The time at which the job should be executed.
    # @param max_retries [Integer] - Times the job should be retried if it fails.
    # @return [JobWrapper] - The job wrapper for the queue.
    def perform(job, at: nil, max_retries: 5)
      if job.instance_of?(Proc) && !at.nil?
        log "Passing a proc and at time is deprecated and will be removed in 0.6"
      end

      job_wrapper = if job.is_a?(JobWrapper)
                      job
                    else
                      JobWrapper.new(job: job, at: at, max_retries: max_retries)
                    end
      queue.push(job_wrapper)
      table[job_wrapper.object_id] = job_wrapper
    rescue DRb::DRbConnError
      bank.push(job_wrapper)
    end
    alias perform_belated perform
    alias perform_later perform

    private

    def drb_connected?
      queue.connected?
    rescue StandardError
      false
    end
  end
end
