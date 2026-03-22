# frozen_string_literal: true

require_relative 'lib/philiprehberger/approx/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-approx'
  spec.version       = Philiprehberger::Approx::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']

  spec.summary       = 'Epsilon-based approximate equality for floats, arrays, and hashes'
  spec.description   = 'Compare numeric values, arrays, and hashes for approximate equality ' \
                       'using configurable epsilon tolerance with deep comparison support.'
  spec.homepage      = 'https://github.com/philiprehberger/rb-approx'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['changelog_uri']         = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']       = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
