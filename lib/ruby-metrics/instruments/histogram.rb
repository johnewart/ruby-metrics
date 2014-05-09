require_relative 'instrument'
require 'ruby-metrics/statistics/uniform_sample'
require 'ruby-metrics/statistics/exponential_sample'

module Metrics
  module Instruments
    class Histogram < Instrument

      def initialize(type = :uniform)
        @count = 0
        case type
        when :uniform
          @sample = Metrics::Statistics::UniformSample.new
        when :exponential
          @sample = Metrics::Statistics::ExponentialSample.new
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
        update_variance(value);
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
        # Calculated using the same logic as R and Ecxel use
        # as outlined by the NIST here: http://www.itl.nist.gov/div898/handbook/prc/section2/prc252.htm
        count = @count
        scores = {}
        values = @sample.values[0..count-1]

        percentiles.each do |pct|
          scores[pct] = 0.0
        end

        if count > 0
          values.sort!
          percentiles.each do |pct|
            idx = pct * (values.length - 1) + 1.0
            if idx <= 1
              scores[pct] = values[0]
            elsif idx >= values.length
              scores[pct] = values[values.length-1]
            else
              lower = values[idx.to_i - 1]
              upper = values[idx.to_i]
              scores[pct] = lower + (idx - idx.floor) * (upper - lower)
            end
          end
        end

        return scores
      end

      def update_min(value)
        if (@min == nil || value < @min)
          @min = value
        end
      end

      def update_max(value)
        if (@max == nil || value > @max)
          @max = value
        end
      end

      def update_variance(value)
        count = @count
        old_m = @variance_m
        new_m = @variance_m + ((value - old_m) / count)
        new_s = @variance_s + ((value - old_m) * (value - new_m))

        @variance_m = new_m
        @variance_s = new_s
      end

      def variance
        count = @count
        variance_s = @variance_s

        if count <= 1
          return 0.0
        else
          return variance_s.to_f / (count - 1).to_i
        end
      end

      def count
        count = @count
        return count
      end


      def max
        max = @max
        if max != nil
          return max
        else
          return 0.0
        end
      end

      def min
        min = @min
        if min != nil
          return min
        else
          return 0.0
        end
      end

      def mean
        count = @count
        sum = @sum

        if count > 0
          return sum / count
        else
          return 0.0
        end
      end

      def std_dev
        count = @count
        variance = self.variance()

        if count > 0
          return Math.sqrt(variance)
        else
          return 0.0
        end
      end

      def values
        @sample.values
      end

      def as_json(*_)
        {
          :min => self.min,
          :max => self.max,
          :mean => self.mean,
          :variance => self.variance,
          :percentiles => self.quantiles([0.25, 0.50, 0.75, 0.95, 0.97, 0.98, 0.99])
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
