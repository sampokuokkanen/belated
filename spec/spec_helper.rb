# frozen_string_literal: true

$TESTING = true
require 'belated'
require 'byebug'
Belated.config.rails_path = './dummy'
Belated.config.workers = 0
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  # config.after(:each) do
  #   Belated.clear_queue!
  #   DRb.stop_service
  #   sleep 0.01
  # end
end
