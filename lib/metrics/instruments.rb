require File.dirname(__FILE__) + '/instruments/base'
require File.dirname(__FILE__) + '/instruments/counter'
require File.dirname(__FILE__) + '/instruments/meter'
require File.dirname(__FILE__) + '/instruments/gauge'

require 'json'

module Metrics
  module Instruments
    @instruments = {}
    
    def self.register(type, name, block = nil)
      case type
      when 'counter'
        instrument = Counter.new
      when 'meter'
        instrument = Meter.new
      when 'gauge'
        if block != nil
          instrument = Gauge.new(block)
        else
          raise "Can't create a gauge without a block"
        end
      end
      
      @instruments[name] = instrument
    end
    
    def self.unregister_all
      @instruments = {}
    end
    
    def self.registered
      @instruments
    end
    
    def self.to_json
      @instruments.to_json 
    end
  end
end
