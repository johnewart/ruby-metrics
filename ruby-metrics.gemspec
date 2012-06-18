# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby-metrics/version"

Gem::Specification.new do |s|
  s.name        = "ruby-metrics"
  s.version     = Metrics::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Ewart"]
  s.email       = ["john@johnewart.net"]
  s.homepage    = "https://github.com/johnewart/ruby-metrics"
  s.summary     = %q{Metrics for Ruby}
  s.description = %q{A Ruby implementation of metrics inspired by @coda's JVM metrics for those of us in Ruby land}

  s.rubyforge_project = "ruby-metrics"

  s.add_dependency "json"

  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov", [">= 0.3.8"] #, :require => false
  s.add_development_dependency "rack-test"
  s.add_development_dependency "gmetric"
  s.add_development_dependency "opentsdb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
