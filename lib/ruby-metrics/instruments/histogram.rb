require_relative 'instrument'
require 'ruby-metrics/statistics/uniform_sample'
require 'ruby-metrics/statistics/exponential_sample'

module Metrics
  module Instruments
    class Histogram < Instrument
      attr_reader :count

      def initialize(type = :uniform)
        @count = 0
        @sample =
          case type
          when :uniform
            Metrics::Statistics::UniformSample.new
          when :exponential
            Metrics::Statistics::ExponentialSample.new
          else
            raise ArgumentError, "Unknown type #{type.inspect}"
          end
        @min = nil
        @max = nil
        @sum = 0
        @variance_s = 0
        @variance_m = -1
      end

      def update(value)
      	@count += 1
      	@sum += value
      	@sample.update(value)
      	update_max(value)
      	update_min(value)
        update_variance(value)
      end

      def clear
        @sample.clear
        @min = nil
        @max = nil
        @sum = 0
        @count = 0
        @variance_m = -1
        @variance_s = 0
      end

      def quantiles(percentiles)
        # Calculated using the same logic as R and Excel use
        # as outlined by the NIST here: http://www.itl.nist.gov/div898/handbook/prc/section2/prc252.htm

        sorted_values = @sample.values[0...@count].sort
        scores = { }
        percentiles.each do |pct|
          scores[pct] =
            if @count == 0
              0.0
            else
              index = pct * (sorted_values.length - 1) + 1.0
              if index <= 1
                sorted_values.first
              elsif index >= sorted_values.length
                sorted_values.last
              else
                lower = sorted_values[index.to_i - 1]
                upper = sorted_values[index.to_i]
                lower + (index - index.floor) * (upper - lower)
              end
          end
        end
        scores
      end

      def update_min(value)
        if @min.nil? || value < @min
          @min = value
        end
      end

      def update_max(value)
        if @max.nil? || value > @max
          @max = value
        end
      end

      def update_variance(value)
        old_m = @variance_m
        new_m = @variance_m + ((value - old_m) / @count)
        new_s = @variance_s + ((value - old_m) * (value - new_m))

        @variance_m = new_m
        @variance_s = new_s
      end

      def variance
        if @count <= 1
          0.0
        else
          @variance_s.to_f / (@count - 1)
        end
      end

      def max
        @max || 0.0
      end

      def min
        @min || 0.0
      end

      def mean
        if @count > 0
          @sum / @count
        else
          0.0
        end
      end

      def std_dev
        if @count > 0
          Math.sqrt(variance)
        else
          0.0
        end
      end

      def values
        @sample.values
      end

      def as_json(*_)
        {
          :min         => min,
          :max         => max,
          :mean        => mean,
          :variance    => variance,
          :percentiles => quantiles(Timer::DEFAULT_PERCENTILES)
        }
      end

      def to_json(*_)
        as_json.to_json
      end
    end

    class ExponentialHistogram < Histogram
      def initialize
        super(:exponential)
      end
    end

    class UniformHistogram < Histogram
      def initialize
        super(:uniform)
      end
    end
  end
end
