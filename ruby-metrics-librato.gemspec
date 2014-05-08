# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'ruby-metrics/version'

Gem::Specification.new do |s|
  s.name        = 'ruby-metrics-librato'
  s.version     = Metrics::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['John Ewart']
  s.email       = ['john@johnewart.net']
  s.homepage    = 'https://github.com/johnewart/ruby-metrics'
  s.summary     = %q{Librato reporter for ruby-metrics}
  s.description = %q{A reporter that uses Librato to stash metric data}
  s.license     = 'MIT'

  s.files         = ['lib/ruby-metrics/reporters/librato.rb']
  s.require_paths = ['lib']

  s.add_dependency 'ruby-metrics', Metrics::VERSION
end
