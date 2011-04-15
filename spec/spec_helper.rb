require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
  add_group "Instruments", "metrics/instruments"
  add_group "Statistical Samples", "metrics/statistics"
  merge_timeout 3600
end

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'ruby-metrics'

RSpec.configure do |config|
  config.mock_with :rspec
end
