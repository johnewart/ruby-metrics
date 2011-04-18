require File.join(File.dirname(__FILE__), 'time_units')

require File.join(File.dirname(__FILE__), 'statistics', 'sample')
require File.join(File.dirname(__FILE__), 'statistics', 'uniform_sample')
require File.join(File.dirname(__FILE__), 'statistics', 'exponential_sample')

require File.join(File.dirname(__FILE__), 'instruments', 'base')
require File.join(File.dirname(__FILE__), 'instruments', 'counter')
require File.join(File.dirname(__FILE__), 'instruments', 'meter')
require File.join(File.dirname(__FILE__), 'instruments', 'gauge')
require File.join(File.dirname(__FILE__), 'instruments', 'histogram')
require File.join(File.dirname(__FILE__), 'instruments', 'timer')


require 'json'

module Metrics
  module Instruments
    @instruments = {}
    
    @types = {
      :counter                => Counter,
      :meter                  => Meter,
      :gauge                  => Gauge,
      :exponential_histogram  => ExponentialHistogram,
      :uniform_histogram      => UniformHistogram,
      :timer                  => Timer
    }
    
    def self.register_with_options(type, name, options = {})
      @instruments[name] = @types[type].new(options)
    end
    
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
      
      def register_with_options(type, name, options)
        Metrics::Instruments.register_with_options(type, name, options)
      end
      
      def counter(name)
        register(:counter, name)
      end
      
      def meter(name)
        register(:meter, name)
      end
      
      def gauge(name, &block)
        register(:gauge, name, &block)
      end
      
      def timer(name, options = {})
        register_with_options(:timer, name, options)
      end      

      def uniform_histogram(name)
        register(:uniform_histogram, name)
      end
      
      # For backwards compatibility
      alias_method :histogram, :uniform_histogram
      
      def exponential_histogram(name)
        register(:exponential_histogram, name)
      end
    end
    
  end
end
