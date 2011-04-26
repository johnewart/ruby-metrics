require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
  add_group "Instruments", "metrics/instruments"
  add_group "Statistical Samples", "metrics/statistics"
  merge_timeout 3600
end

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'ruby-metrics'

Metrics.logger = Logger.new(STDERR)
Metrics.logger.level = Logger::INFO

RSpec.configure do |config|
  config.mock_with :rspec
end
