# frozen_string_literal: true

require_relative 'lib/hard_worker/version'

Gem::Specification.new do |spec|
  spec.name          = 'hard_worker'
  spec.version       = HardWorker::VERSION
  spec.authors       = ['Sampo Kuokkanen']
  spec.email         = ['sampo.kuokkanen@gmail.com']

  spec.summary       = 'Just another Ruby background job library.'
  spec.description   = %(
    A very, very simple Ruby background job library, that does not have many features, and almost works.
  ).gsub(/\s+/, ' ').strip
  spec.homepage      = 'https://github.com/sampokuokkanen/hard_worker'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = 'bin'
  spec.executables   = ['hard_worker']
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'drb'
  spec.add_development_dependency 'byebug'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
