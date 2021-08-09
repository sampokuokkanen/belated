require 'securerandom'

class Belated
  class JobWrapper
    attr_accessor :retries, :max_retries, :id, :job, :at

    def initialize(max_retries: 5, job:, at: nil)
      self.retries = 0
      self.max_retries = max_retries
      self.id = SecureRandom.uuid
      self.job = job
      self.at = at
    end
  end
end