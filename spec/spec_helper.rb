# frozen_string_literal: true

$TESTING = true
require 'ruby2_keywords'
require 'belated'
require 'byebug'
Belated.configure do |config|
  config.env = 'test'
  config.rails_path = './dummy'
  config.workers = 0
  config.client_heartbeat = 0.04
  config.heartbeat = 0.04
end

Thread.abort_on_exception = true
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.after(:each) do
    Belated.kill_and_clear_queue!
    if File.exist? "history-#{Time.now.strftime("%F")}.pstore"
      File.delete "history_#{Belated.env}-#{Time.now.strftime("%F")}.pstore"
    end
    File.delete "future_jobs_#{Belated.env}.pstore" if File.exist? "future_jobs_#{Belated.env}.pstore"
  end

  # config.around(:each) do |example|
  #   path = "./stackprof-cpu-test-#{example.full_description.parameterize}.dump"
  #   StackProf.run(mode: :cpu, out: path.to_s) do
  #     example.run
  #   end
  # end
end
