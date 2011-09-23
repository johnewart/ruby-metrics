require File.join(File.dirname(__FILE__), '..', 'time_units')

module Metrics
  module Instruments
    class Timer < Base
      include Metrics::TimeConversion 
      
      attr_reader :duration_unit, :rate_unit
      
      def initialize(options = {})
        @meter          = Meter.new
        @histogram      = ExponentialHistogram.new

        @duration_unit  = options[:duration_unit] || :seconds
        @rate_unit      = options[:rate_unit] || :seconds
        
        clear
      end
      
      def clear
        @histogram.clear
      end

      def update(duration, unit)
        mult = convert_to_ns(1, unit)
        self.update_timer(duration * mult)
      end

      def time(&block) 
        start_time = Time.now.to_f
        result = block.call
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
      
      def quantiles(percentiles = [0.99,0.97,0.95,0.75,0.5,0.25])
        result = {}
        
        @histogram.quantiles(percentiles).each do |k,v|
          result[k] = scale_duration_to_ns v, @duration_unit
        end
        
        result
      end

      def values
        result = []

        @histogram.values.each do |value|
          result << (scale_duration_to_ns value, @duration_unit)
        end
        
        result
      end
      
      def update_timer(duration)
        if duration >= 0
          @histogram.update(duration)
          @meter.mark
        end
      end
      
      def to_json(*_)
        {
          :count => self.count,
          :rates => {
            :one_minute_rate => self.one_minute_rate,
            :five_minute_rate => self.five_minute_rate,
            :fifteen_minute_rate => self.fifteen_minute_rate, 
            :unit => @rate_unit
          },
          :durations => { 
            :min => self.min,
            :max => self.max,
            :mean => self.mean,
            :percentiles => self.quantiles([0.25, 0.50, 0.75, 0.95, 0.97, 0.98, 0.99]),
            :unit => @duration_unit
          }
        }.to_json
      end
      
      private
      def scale_duration_to_ns(value, unit)
        value.to_f / convert_to_ns(1, unit).to_f
      end
      
    end

    register_instrument(:timer, Timer)
  end
end  
      
