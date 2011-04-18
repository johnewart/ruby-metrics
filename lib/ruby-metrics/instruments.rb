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
      :uniform_histogram      => UniformHistogram
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

    def self.types
      @types
    end
    
    def self.to_json
      registered.to_json 
    end

    module Instrumentation

      Metrics::Instruments.types.each do |instrument, klass|

        define_method(instrument) do |name, &block|
          Metrics::Instruments.register(instrument, name, &block)
        end

      end

      # For backwards compatibility
      alias_method :histogram, :uniform_histogram
    
    end
    
  end
end
