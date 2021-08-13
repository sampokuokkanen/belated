require 'belated/job_wrapper'
class Belated
  # The client class is responsible for managing the connection to the
  # DRb server. If it has no connection, it adds the jobs to a bank queue.
  # You can enqueue jobs to be processed by the server.
  # Example:
  #   client = Belated::Client.new
  #   client.enqueue(JubJub.new, at: Time.now + 5.seconds)
  class Client
    attr_accessor :queue, :bank, :banker_thread

    # Starts up the client.
    # Connects to the queue through DRb.
    # @return [void]
    def initialize
      server_uri = Belated::URI
      DRb.start_service
      self.bank = Thread::Queue.new
      self.queue = DRbObject.new_with_uri(server_uri)
    end

    # Thread in charge of handling the bank queue.
    # You probably want to memoize the client in order to avoid
    # having many threads in the sleep state.
    # @return [void]
    def start_banker_thread
      self.banker_thread = Thread.new do
        loop do
          sleep 0.01
          unless drb_connected?
            sleep(10)
            next
          end

          job = bank.pop

          perform(job)
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
      job_wrapper = if job.is_a?(JobWrapper)
                      job
                    else
                      JobWrapper.new(job: job, at: at, max_retries: max_retries)
                    end
      pp queue.push(job_wrapper)
      job_wrapper
    rescue DRb::DRbConnError
      bank.push(job_wrapper)
      start_banker_thread if banker_thread.nil?
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
