require File.dirname(__FILE__) + '/instruments/base'
require File.dirname(__FILE__) + '/instruments/counter'
require File.dirname(__FILE__) + '/instruments/timer'

require 'json'

module Metrics
  module Instruments
    @instruments = {}
    
    def self.register(type, name)
      case type
      when 'counter'
        instrument = Counter.new()
      when 'timer'
        instrument = Timer.new()
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
