# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'rails'
require_relative '../dummy/config/environment'
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../dummy/db/migrate', __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
