require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
  add_group "Instruments", "lib/metrics/instruments"
  merge_timeout 3600
end

require File.dirname(__FILE__) + "/../lib/metrics"

RSpec.configure do |config|
  config.mock_with :rspec
end