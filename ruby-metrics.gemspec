# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'ruby-metrics/version'

plugin_files = Dir['ruby-metrics-*.gemspec'].map { |gemspec|
    eval(File.read(gemspec)).files
}.flatten.uniq

Gem::Specification.new do |s|
  s.name        = 'ruby-metrics'
  s.version     = Metrics::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['John Ewart']
  s.email       = ['john@johnewart.net']
  s.homepage    = 'https://github.com/johnewart/ruby-metrics'
  s.summary     = %q{Metrics for Ruby}
  s.description = %q{A Ruby implementation of metrics inspired by @coda's JVM metrics for those of us in Ruby land}
  s.license     = 'MIT'

  s.add_dependency 'json', '~> 1.5', '>= 1.5.5'

  s.add_development_dependency 'rspec', '~> 2.14', '>= 2.14.0'
  s.add_development_dependency 'simplecov', '~> 0.3', '>= 0.3.8'
  s.add_development_dependency 'rack-test', '~> 0.5', '>= 0.5.7'

  s.files         = `git ls-files`.split("\n") - plugin_files
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
