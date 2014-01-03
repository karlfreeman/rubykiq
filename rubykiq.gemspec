# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubykiq/version'

Gem::Specification.new do |spec|
  spec.name          = 'rubykiq'
  spec.version       = Rubykiq::VERSION
  spec.authors       = ['Karl Freeman']
  spec.email         = ['karlfreeman@gmail.com']
  spec.summary       = %q{Sidekiq agnostic enqueuing using Redis}
  spec.description   = %q{Sidekiq agnostic enqueuing using Redis}
  spec.homepage      = 'https://github.com/karlfreeman/rubykiq'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency 'redis', '>= 3.0'
  spec.add_dependency 'redis-namespace', '>= 1.0'
  spec.add_dependency 'multi_json', '>= 1.0'
  spec.add_dependency 'connection_pool', '>= 1.0'
end
