class FailJob < ApplicationJob
  retry_on RuntimeError, attempts: 5, wait: 0.2

  def perform
    @retries ||= -1
    @retries += 1
    raise "This job is supposed to fail" if @retries < 4

    'Hello, World!'
  end
end