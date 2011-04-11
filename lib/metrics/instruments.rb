require File.join(File.dirname(__FILE__), 'instruments', 'base')
require File.join(File.dirname(__FILE__), 'instruments', 'counter')
require File.join(File.dirname(__FILE__), 'instruments', 'meter')
require File.join(File.dirname(__FILE__), 'instruments', 'gauge')

require 'json'

module Metrics
  module Instruments
    @instruments = {}
    
    @types = {
      :counter  => Counter,
      :meter    => Meter,
      :gauge    => Gauge,
    }
    
    def self.register(type, name, &block)
      @instruments[name] = @types[type].new(&block)
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
    
    module TypeMethods
      
      def register(type, name, &block)
        Metrics::Instruments.register(type, name, &block)
      end
      
      def counter(name)
        register(:counter, name)
      end
      
      def meter(name)
        register(:counter, name)
      end
      
      def gauge(name, &block)
        register(:gauge, name, &block)
      end
      
    end
    
  end
end
