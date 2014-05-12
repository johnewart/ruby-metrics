require_relative 'instrument'
require 'ruby-metrics/time_units'

module Metrics
  module Instruments
    class Timer < Instrument
      include Metrics::TimeConversion

      attr_reader :duration_unit, :rate_unit, :units

      DEFAULT_PERCENTILES = [0.25, 0.50, 0.75, 0.95, 0.97, 0.98, 0.99]

      def initialize(options = {})
        @meter          = Meter.new
        @histogram      = ExponentialHistogram.new

        @duration_unit  = options[:duration_unit] || :seconds
        @rate_unit      = options[:rate_unit] || :seconds
        @units          = options[:units]
        
        clear
      end

      def clear
        @meter.clear
        @histogram.clear
      end

      def update(duration, unit)
        update_timer(convert_to_ns(duration, unit))
      end

      def time
        start_time = Time.now.to_f
        result = yield
        time_diff = Time.now.to_f - start_time
        time_in_ns = convert_to_ns time_diff, :seconds
        update_timer(time_in_ns)
        result
      end

      def count
        @histogram.count
      end

      def fifteen_minute_rate
        @meter.fifteen_minute_rate(@rate_unit)
      end

      def five_minute_rate
        @meter.five_minute_rate(@rate_unit)
      end

      def one_minute_rate
        @meter.one_minute_rate(@rate_unit)
      end

      def mean_rate
        @meter.mean_rate(@rate_unit)
      end

      def max
        scale_duration_to_ns @histogram.max, @duration_unit
      end

      def min
        scale_duration_to_ns @histogram.min, @duration_unit
      end

      def mean
        scale_duration_to_ns @histogram.mean, @duration_unit
      end

      def std_dev
        scale_duration_to_ns @histogram.std_dev, @duration_unit
      end

      def quantiles(percentiles = DEFAULT_PERCENTILES)
        @histogram.quantiles(percentiles).inject({}) do |result, (k, v)|
          result[k] = scale_duration_to_ns v, @duration_unit
          result
        end
      end

      def values
        @histogram.values.map do |value|
          scale_duration_to_ns value, @duration_unit
        end
      end

      def update_timer(duration)
        if duration >= 0
          @histogram.update(duration)
          @meter.mark
        end
      end

      def as_json(*_)
        {
          :count => count,
          :rates => {
            :one_minute_rate => one_minute_rate,
            :five_minute_rate => five_minute_rate,
            :fifteen_minute_rate => fifteen_minute_rate,
            :unit => @rate_unit
          },
          :durations => {
            :min => min,
            :max => max,
            :mean => mean,
            :percentiles => quantiles,
            :unit => @duration_unit
          }
        }
      end

      def to_json(*_)
        as_json.to_json
      end

      private
      def scale_duration_to_ns(value, unit)
        value.to_f / convert_to_ns(1.0, unit)
      end
    end
  end
end
