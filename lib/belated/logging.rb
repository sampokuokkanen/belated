class Belated
  module Logging
    extend self
    
    def logger
      @logger ||= Belated.logger
    end

    def log(message)
      logger.__send__(Belated.log_level, message)
    end

    def logger=(logger)
      @logger = logger
    end
  end
end