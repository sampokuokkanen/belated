class Belated
  # Logger for Belated.
  # Include this module in your class to get a logger.
  module Logging
    extend self

    def logger
      @logger ||= Belated.logger
    end

    def log(message)
      logger.__send__(Belated.log_level, message)
    end

    def warn(message)
      logger.warn(message)
    end

    def error(message)
      logger.error(message)
    end

    def logger=(logger)
      @logger = logger
    end
  end
end
