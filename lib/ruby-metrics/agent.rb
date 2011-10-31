require 'ruby-metrics/logging'

require 'ruby-metrics/time_units'

require 'ruby-metrics/instruments/counter'
require 'ruby-metrics/instruments/meter'
require 'ruby-metrics/instruments/gauge'
require 'ruby-metrics/instruments/histogram'
require 'ruby-metrics/instruments/timer'

require 'ruby-metrics/integration'

require 'json'

module Metrics
  class Agent
    include Logging

    attr_reader :instruments

    def initialize(options = {})
      @instruments = {}
    end

    alias_method :registered, :instruments

    def counter(name)
      @instruments[name] ||= Instruments::Counter.new
    end

    def meter(name)
      @instruments[name] ||= Instruments::Meter.new
    end

    def gauge(name, &block)
      @instruments[name] ||= Instruments::Gauge.new(&block)
    end

    def timer(name, options = {})
      @instruments[name] ||= Instruments::Timer.new(options)
    end

    def uniform_histogram(name)
      @instruments[name] ||= Instruments::UniformHistogram.new
    end

    # For backwards compatibility
    alias_method :histogram, :uniform_histogram

    def exponential_histogram(name)
      @instruments[name] ||= Instruments::ExponentialHistogram.new
    end

    def to_json
      @instruments.to_json
    end
  end
end
