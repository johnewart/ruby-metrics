# == Metrics Initialization
#
# When installed as a gem, you can activate the Metrics agent one of the following ways:
#
# For Rails, add:
#    config.gem 'metrics'
# to your initialization sequence.
#
# For other frameworks, or to manage the agent manually, invoke Metrics::Agent#manual_start
# directly.
#
require File.dirname(__FILE__) + '/metrics/agent'

module Metrics
  
  class << self
    attr_writer :logger
    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
  
end
