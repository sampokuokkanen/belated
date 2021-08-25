# frozen_string_literal: true

$TESTING = true
require 'ruby2_keywords'
require 'belated'
require 'byebug'
Belated.config.rails_path = './dummy'
Belated.config.workers = 0
Belated.config.client_heartbeat = 0.1
Belated.config.heartbeat = 0.05
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
  end

  # config.around(:each) do |example|
  #   path = "./stackprof-cpu-test-#{example.full_description.parameterize}.dump"
  #   StackProf.run(mode: :cpu, out: path.to_s) do
  #     example.run
  #   end
  # end
end
