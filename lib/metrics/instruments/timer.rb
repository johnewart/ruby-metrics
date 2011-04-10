require 'ruby-units'

INTERVAL = "5 seconds"
INTERVAL_IN_NS = INTERVAL.to("nanoseconds").scalar
ONE_MINUTE_FACTOR = 1 / Math.exp(INTERVAL.to("minutes").scalar)
FIVE_MINUTE_FACTOR = ONE_MINUTE_FACTOR / 5
FIFTEEN_MINUTE_FACTOR = ONE_MINUTE_FACTOR / 15

module Metrics
  module Instruments
    class Timer < Base
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
          @rateunit = "1 second"
        end
        
        @ratemultiplier = @rateunit.to("nanoseconds").scalar 
        
        unless options[:nothread] == true
          @timer_thread = Thread.new do
            sleep_time = interval.to("seconds").scalar
            begin
              while(true)
                self.tick
                sleep(sleep_time)
              end
            rescue Exception => e
              logger.error "Error in timer thread: #{e.class.name}: #{e}\n  #{e.backtrace.join("\n  ")}"
            end # begin
          end # thread new
        end
      end
            
      def clear
      end
      
      def mark(count = 1)
        @uncounted += count
        @counted += count
      end
      
      def tick
        count = @uncounted 
        if (@initialized)
          @one_minute_rate     += (ONE_MINUTE_FACTOR.to_f * ((count.to_f / INTERVAL_IN_NS.to_f) - @one_minute_rate.to_f))
          @five_minute_rate    += (FIVE_MINUTE_FACTOR.to_f * ((count.to_f / INTERVAL_IN_NS.to_f) - @five_minute_rate.to_f))
          @fifteen_minute_rate += (FIFTEEN_MINUTE_FACTOR.to_f * ((count.to_f / INTERVAL_IN_NS.to_f) - @fifteen_minute_rate.to_f))
        else
          @one_minute_rate = @five_minute_rate = @fifteen_minute_rate  = (count.to_f / INTERVAL_IN_NS.to_f)
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
        return {
          :one_minute_rate => self.one_minute_rate,
          :five_minute_rate => self.five_minute_rate,
          :fifteen_minute_rate => self.fifteen_minute_rate
        }.to_json
      end
    end
  end
end
