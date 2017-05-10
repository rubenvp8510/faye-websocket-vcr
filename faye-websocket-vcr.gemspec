# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faye-websocket-vcr/version'

Gem::Specification.new do |gem|
  gem.name          = 'faye-websocket-vcr'
  gem.version       = WebSocketVCR::VERSION
  gem.authors       = ['Jirka Kremser']
  gem.email         = ['jkremser@redhat.com']
  gem.description   = 'Websocket VCR add-on'
  gem.summary       = 'faye-websocket-vcr is VCR add-on for websockets.'
  gem.homepage      = 'https://github.com/Jiri-Kremser/simple-websocket-vcr'
  gem.license       = 'Apache-2.0'
  gem.required_ruby_version = '>= 2.0.0'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'faye-websocket'

  gem.add_development_dependency 'coveralls', '~> 0.8'
  gem.add_development_dependency 'rspec-rails', '~> 3.0'
  gem.add_development_dependency 'rake', '~> 11'
  gem.add_development_dependency 'rubocop', '= 0.34.2'
  gem.add_development_dependency 'shoulda', '~> 3.5'
  gem.add_development_dependency 'vcr', '~> 2.9'
  gem.add_development_dependency 'webmock', '~> 1.7'
  gem.add_development_dependency 'rspec-eventmachine', '>= 0.2.0'
end
