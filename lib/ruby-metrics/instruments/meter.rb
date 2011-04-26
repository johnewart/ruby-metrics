require File.join(File.dirname(__FILE__), '..', 'time_units')

module Metrics
  module Instruments
    class Meter < Base
      include Metrics::TimeConversion 
      
      # From http://www.teamquest.com/pdfs/whitepaper/ldavg2.pdf
      INTERVAL = 5.0
      INTERVAL_IN_NS = 5000000000.0
      ONE_MINUTE_FACTOR     = 1 - Math.exp(-INTERVAL / 60.0)
      FIVE_MINUTE_FACTOR    = 1 - Math.exp(-INTERVAL / (60.0 * 5.0))
      FIFTEEN_MINUTE_FACTOR = 1 - Math.exp(-INTERVAL / (60.0 * 15.0))
      
      attr_reader :count
      alias_method :counted, :count
      
      def initialize(options = {})
        @one_minute_rate = @five_minute_rate = @fifteen_minute_rate = 0.0
        @count  = 0
        @initialized = false
        @start_time = Time.now.to_f
                        
        @timer_thread = Thread.new do
          sleep_time = INTERVAL
          begin
            loop do
              self.tick
              sleep(sleep_time)
            end
          rescue Exception => e
            logger.error "Error in timer thread: #{e.class.name}: #{e}\n  #{e.backtrace.join("\n  ")}"
          end # begin
        end # thread new

      end
      
      def clear
      end
      
      def mark(count = 1)
        @count += count
      end
      
      def calc_rate(rate, factor, count)
        rate = rate.to_f + (factor.to_f * (count.to_f - rate.to_f))
        rate.to_f
      end
      
      def tick
        count = @count.to_f  / Seconds.to_nsec(INTERVAL).to_f

        if (@initialized)
          @one_minute_rate      = calc_rate(@one_minute_rate,     ONE_MINUTE_FACTOR,     count)
          @five_minute_rate     = calc_rate(@five_minute_rate,    FIVE_MINUTE_FACTOR,    count)
          @fifteen_minute_rate  = calc_rate(@fifteen_minute_rate, FIFTEEN_MINUTE_FACTOR, count)
        else
          @one_minute_rate = @five_minute_rate = @fifteen_minute_rate  = (count)
          @initialized = true
        end
        
        @count = 0
      end
      
      def one_minute_rate(rate_unit = :seconds)
        convert_to_ns @one_minute_rate, rate_unit
      end
      
      def five_minute_rate(rate_unit = :seconds)
        convert_to_ns @five_minute_rate, rate_unit
      end
      
      def fifteen_minute_rate(rate_unit = :seconds)
        convert_to_ns @fifteen_minute_rate, rate_unit
      end
      
      def mean_rate(rate_unit = :seconds)
        count = @count
        if count == 0
          return 0.0;
        else
          elapsed = Time.now.to_f - @start_time.to_f
          convert_to_ns (count.to_f / elapsed.to_f), rate_unit
        end
      end
      
      def to_s
        {
          :one_minute_rate => self.one_minute_rate,
          :five_minute_rate => self.five_minute_rate,
          :fifteen_minute_rate => self.fifteen_minute_rate
        }.to_json
      end
      
    end

    register_instrument(:meter, Meter)
  end
end
