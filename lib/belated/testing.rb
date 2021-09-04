class Belated
  # Testing helpers
  # Enable or disable testing
  class Testing
    @@testing = false

    def self.inline?
      @@testing == true
    end

    def self.inline!
      @@testing = true
    end

    def self.test_mode_off!
      @@testing = false
    end
  end
end

class Belated
  # A client that can perform jobs inline
  class Client
    alias old_perform perform
    def perform(job, at: nil, max_retries: 5, active_job: false)
      if Belated::Testing.inline?
        if job.respond_to?(:call)
          job.call
        else
          job.perform
        end
      else
        old_perform(job, at: at, max_retries: max_retries, active_job: active_job)
      end
    end
  end
end
