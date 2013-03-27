# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'rubykiq/version'

Gem::Specification.new do |gem|
  gem.add_dependency 'redis', '~> 3'
  gem.add_dependency 'redis-namespace'
  gem.add_dependency 'multi_json', '~> 1'
  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.name          = 'rubykiq'
  gem.version       = Rubykiq::VERSION
  gem.authors       = ['Karl Freeman']
  gem.email         = ['karlfreeman@gmail.com']
  gem.license       = 'MIT'
  gem.description   = %q{Sidekiq agnostic enqueuing using Redis}
  gem.summary       = %q{Sidekiq agnostic enqueuing using Redis}
  gem.homepage      = 'https://github.com/karlfreeman/rubykiq'
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 1.9.2'
end
