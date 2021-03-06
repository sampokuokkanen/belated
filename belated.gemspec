# frozen_string_literal: true

require_relative 'lib/belated/version'

Gem::Specification.new do |spec|
  spec.name          = 'belated'
  spec.version       = Belated::VERSION
  spec.authors       = ['Sampo Kuokkanen']
  spec.email         = ['sampo.kuokkanen@gmail.com']

  spec.summary       = 'Run background jobs with Belated and dRuby!'
  spec.description   = %(
    A simple Ruby backend job framework without Redis or PostgreSQL dependency.
    Used to be named HardWorker.
  ).gsub(/\s+/, ' ').strip
  spec.homepage      = 'https://github.com/sampokuokkanen/belated'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|dummy|spec|features)/}) }
  end
  spec.bindir = 'bin'
  spec.executables   = ['belated']
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'drb'
  spec.add_dependency 'dry-configurable'
  spec.add_dependency 'ruby2_keywords'
  spec.add_dependency 'pstore'
  spec.add_dependency 'sorted_set'
  spec.add_development_dependency 'byebug'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
