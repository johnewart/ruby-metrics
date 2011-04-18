# == Metrics Initialization
#
require 'quantity/all'

module Metrics
  
  class << self
    attr_writer :logger
    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
  
end

Quantity::Unit.add_unit :minute,  :time, 60000,     :minutes
Quantity::Unit.add_unit :hour,    :time, 3600000,   :hours
Quantity::Unit.add_unit :day,     :time, 86400000,  :days
Quantity::Unit.add_unit :week,    :time, 604800000, :weeks


require File.join(File.dirname(__FILE__), 'ruby-metrics', 'agent')
