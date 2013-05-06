require 'ruby-metrics/logging'

require 'ruby-metrics/time_units'

require 'ruby-metrics/instruments/counter'
require 'ruby-metrics/instruments/meter'
require 'ruby-metrics/instruments/gauge'
require 'ruby-metrics/instruments/histogram'
require 'ruby-metrics/instruments/timer'

require 'ruby-metrics/integration'
require 'ruby-metrics/reporter'

require 'json'

module Metrics
  class Agent
    include Logging

    attr_reader :instruments, :reporters

    def initialize(options = {})
      @instruments = {}
      @reporters = {}
    end

    alias_method :registered, :instruments

    def counter(name, units = "")
      @instruments[name] ||= Instruments::Counter.new(:units => units)
    end

    def meter(name, units = "")
      @instruments[name] ||= Instruments::Meter.new(:units => units)
    end

    def gauge(name, units = "", &block)
      @instruments[name] ||= Instruments::Gauge.new(:units => units, &block)
    end

    def timer(name, units = "", options = {})
      @instruments[name] ||= Instruments::Timer.new(options.merge(:units => units))
    end

    def uniform_histogram(name, units = "")
      @instruments[name] ||= Instruments::UniformHistogram.new
    end

    # For backwards compatibility
    alias_method :histogram, :uniform_histogram

    def exponential_histogram(name, units = "")
      @instruments[name] ||= Instruments::ExponentialHistogram.new
    end

    def report_to(name, options = {})
      @reporters[name] ||= Reporter.new({:agent => self}.merge(options))
    end

    def as_json(*_)
      @instruments
    end

    def to_json(*_)
      as_json.to_json
    end
  end
end
