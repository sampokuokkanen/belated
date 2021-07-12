# frozen_string_literal: true

require_relative "hard_worker/version"
require_relative "hard_worker/worker"

module HardWorker
  extend self
  class Error < StandardError; end
  @@job_queu = []

  def job_queue
    @@job_queu
  end
end
