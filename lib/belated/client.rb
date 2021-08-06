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
          job, at = bank.pop

          perform(job, at: at)
        end
      end
    end

    # The method that pushes the jobs to the queue.
    # If there is no connection, it pushes the job to the bank.
    # @param job [Object] - The the job to be pushed.
    # @param at [Date] - The time at which the job should be executed.
    # @return [Object] - The job that was pushed.
    def perform(job, at: nil)
      queue.push(job, at: at)
    rescue DRb::DRbConnError
      bank.push([job, at])
      start_banker_thread if banker_thread.nil?
      # banker_thread.wakeup if banker_thread.status == 'sleep'
    end
    alias perform_belated perform
    alias perform_later perform
  end
end
