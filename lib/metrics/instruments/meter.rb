require 'ruby-units'

module Metrics
  module Instruments
    class Meter < Base
      # From http://www.teamquest.com/pdfs/whitepaper/ldavg2.pdf
      INTERVAL = 5.0
      INTERVAL_IN_NS = 5000000000.0
      ONE_MINUTE_FACTOR     = 1 - Math.exp(-INTERVAL / 60.0)
      FIVE_MINUTE_FACTOR    = 1 - Math.exp(-INTERVAL / (60.0 * 5.0))
      FIFTEEN_MINUTE_FACTOR = 1 - Math.exp(-INTERVAL / (60.0 * 15.0))
      
      attr_reader :counted, :uncounted
      
      def initialize(options = {})
        @one_minute_rate = @five_minute_rate = @fifteen_minute_rate = 0.0
        @counted = @uncounted = 0
        @initialized = false
        
        if options[:interval]
          interval = options[:interval]
        else
          interval = "5 seconds"
        end
        
        if options[:rateunit]
          @rateunit = options[:rateunit]
        else
          @rateunit = interval
        end
        
        # HACK: this is here because ruby-units thinks 1s in ns is 999,999,999.9999999 not 1bn 
        # TODO: either fix ruby-units, or remove it?
        @ratemultiplier = @rateunit.to("nanoseconds").scalar.ceil
        
        @timer_thread = Thread.new do
          sleep_time = interval.to("seconds").scalar
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
        @uncounted += count
        @counted += count
      end
      
      def calc_rate(rate, factor, count)
        rate = rate + (factor * (count - rate))
        rate
      end
      
      def tick
        count = @uncounted.to_f  / INTERVAL_IN_NS.to_f

        if (@initialized)
          @one_minute_rate      = calc_rate(@one_minute_rate,     ONE_MINUTE_FACTOR,     count)
          @five_minute_rate     = calc_rate(@five_minute_rate,    FIVE_MINUTE_FACTOR,    count)
          @fifteen_minute_rate  = calc_rate(@fifteen_minute_rate, FIFTEEN_MINUTE_FACTOR, count)
        else
          @one_minute_rate = @five_minute_rate = @fifteen_minute_rate  = (count)
          @initialized = true
        end
        
        @uncounted = 0
      end
      
      def one_minute_rate
        @one_minute_rate * @ratemultiplier
      end
      
      def five_minute_rate
        @five_minute_rate * @ratemultiplier
      end
      
      def fifteen_minute_rate
        @fifteen_minute_rate * @ratemultiplier
      end
      
      def to_s
        {
          :one_minute_rate => self.one_minute_rate,
          :five_minute_rate => self.five_minute_rate,
          :fifteen_minute_rate => self.fifteen_minute_rate
        }.to_json
      end
    end
  end
end
