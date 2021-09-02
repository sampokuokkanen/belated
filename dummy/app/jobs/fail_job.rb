class FailJob < ApplicationJob
  retry_on RuntimeError, attempts: 5

  def perform
    @retries ||= -1
    @retries += 1
    raise "This job is supposed to fail" if @retries < 4

    'Hello, World!'
  end
end