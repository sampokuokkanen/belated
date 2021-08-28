class TestJob < ApplicationJob
  queue_as :default

  def perform
    "Test job"
  end
end