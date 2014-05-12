require_relative 'instrument'
require 'ruby-metrics/time_units'

module Metrics
  module Instruments
    class Meter < Instrument
      include Metrics::TimeConversion

      # From http://www.teamquest.com/pdfs/whitepaper/ldavg2.pdf
      INTERVAL_SECONDS = 5.0
      ONE_MINUTE_FACTOR     = 1 - Math.exp(-INTERVAL_SECONDS / 60.0)
      FIVE_MINUTE_FACTOR    = 1 - Math.exp(-INTERVAL_SECONDS / (60.0 * 5.0))
      FIFTEEN_MINUTE_FACTOR = 1 - Math.exp(-INTERVAL_SECONDS / (60.0 * 15.0))

      attr_reader :count, :units
      alias_method :counted, :count

      def initialize(options = {})
        @units = options[:units]
        clear

        @timer_thread = Thread.new do
          begin
            loop do
              tick
              sleep(INTERVAL_SECONDS)
            end
          rescue Exception => e
            logger.error "Error in timer thread: #{e.class.name}: #{e}\n  #{e.backtrace.join("\n  ")}"
          end
        end
      end

      def clear
        @one_minute_rate = @five_minute_rate = @fifteen_minute_rate = 0.0
        @count  = 0
        @initialized = false
        @start_time = Time.now.to_f
      end

      def mark(count = 1)
        @count += count
      end

      def calc_rate(rate, factor, count)
        rate.to_f + factor.to_f * (count.to_f - rate.to_f)
      end

      def tick
        count = @count.to_f / Seconds.to_nsec(INTERVAL_SECONDS).to_f

        if @initialized
          @one_minute_rate      = calc_rate(@one_minute_rate,     ONE_MINUTE_FACTOR,     count)
          @five_minute_rate     = calc_rate(@five_minute_rate,    FIVE_MINUTE_FACTOR,    count)
          @fifteen_minute_rate  = calc_rate(@fifteen_minute_rate, FIFTEEN_MINUTE_FACTOR, count)
        else
          @one_minute_rate = @five_minute_rate = @fifteen_minute_rate  = count
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
        if @count == 0
          0.0
        else
          elapsed = Time.now.to_f - @start_time.to_f
          scale_factor = scale_time_units(:seconds, rate_unit)
          @count.to_f / (elapsed * scale_factor)
        end
      end

      def as_json(*_)
        {
          :one_minute_rate      => one_minute_rate,
          :five_minute_rate     => five_minute_rate,
          :fifteen_minute_rate  => fifteen_minute_rate
        }
      end

      def to_json(*_)
        as_json.to_json
      end
    end
  end
end
