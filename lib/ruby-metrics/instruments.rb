require File.join(File.dirname(__FILE__), 'statistics', 'sample')
require File.join(File.dirname(__FILE__), 'statistics', 'uniform_sample')
require File.join(File.dirname(__FILE__), 'statistics', 'exponential_sample')

require File.join(File.dirname(__FILE__), 'instruments', 'base')
require File.join(File.dirname(__FILE__), 'instruments', 'counter')
require File.join(File.dirname(__FILE__), 'instruments', 'meter')
require File.join(File.dirname(__FILE__), 'instruments', 'gauge')
require File.join(File.dirname(__FILE__), 'instruments', 'histogram')


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

    def self.instruments
      @types.keys
    end
    
    def self.to_json
      @instruments.to_json 
    end

    module Instrumentation

      Metrics::Instruments.instruments.each do |instrument|

        define_method(instrument) do |name, &block|
          Metrics::Instruments.register(instrument, name, &block)
        end

      end

      # For backwards compatibility
      alias_method :histogram, :uniform_histogram
    
    end
    
  end
end
