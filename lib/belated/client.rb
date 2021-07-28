class Belated
  class Client
    attr_accessor :queue

    def initialize
      server_uri = Belated::URI
      @bank = 
      DRb.start_service
      self.queue = DRbObject.new_with_uri(server_uri)
    end

    def perform(job)
      queue.push(job)
    end
    alias perform_belated perform
    alias perform_later perform
  end
end
