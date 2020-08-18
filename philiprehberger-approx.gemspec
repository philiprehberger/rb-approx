# frozen_string_literal: true

require_relative 'lib/philiprehberger/approx/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-approx'
  spec.version = Philiprehberger::Approx::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Epsilon-based approximate equality for floats, arrays, and hashes'
  spec.description = 'Compare numeric values, arrays, and hashes for approximate equality ' \
                       'using configurable epsilon tolerance with deep comparison support.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-approx'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-approx'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-approx/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-approx/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
