# == Metrics Initialization
#

module Metrics
  
  class << self
    attr_writer :logger
    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
  
end

require File.join(File.dirname(__FILE__), 'metrics', 'agent')
