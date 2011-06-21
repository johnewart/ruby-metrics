# == Metrics Initialization
#

require 'logger'

module Metrics
  class << self
    attr_writer :logger
    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end

require 'ruby-metrics/agent'
