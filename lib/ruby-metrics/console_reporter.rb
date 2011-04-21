require File.join(File.dirname(__FILE__), 'logging')
require File.join(File.dirname(__FILE__), 'instruments')
require File.join(File.dirname(__FILE__), 'time_units')

module Metrics
  class ConsoleReporter
    include Logging
    include Instruments::TypeMethods
    
    attr_reader :instruments
    
    def initialize(out = STDOUT)
      logger.debug "Initializing Reporter..."
      @instruments = Metrics::Instruments
      @out = out
    end
    
    def start(period = 10)
      start_reporter_daemon_thread(period)
    end
    
    protected
    def start_reporter_daemon_thread(period)
      logger.debug "Creating Metrics console reporter daemon thread."
      @reporter_daemon_thread = Thread.new do
        begin
          loop do
            start_time = Time.now
            start_time_str = start_time.strftime("%m/%d/%Y %X ")
            @out.print start_time_str
            (80-start_time_str.length-1).times { @out.print('=') }
            @out.puts
            
            print_instruments
            
            @out.puts
            @out.flush
            sleep(period)
          end
        rescue Exception => e
          logger.error "Error in worker thread: #{e.class.name}: #{e}\n  #{e.backtrace.join("\n  ")}"
        end # begin
      end # thread new
    end
    
    def print_instruments
      @instruments.registered.each do |name, metric|
        @out.puts "Name: #{name}, Type: #{metric.class.to_s.gsub(/.+::/, "")}"
        if metric.is_a? Instruments::Gauge
          print_gauge(metric)
        elsif metric.is_a? Instruments::Counter
          print_counter(metric)
        elsif metric.is_a? Instruments::Histogram
          print_histogram(metric)
        elsif metric.is_a? Instruments::Meter
          print_metered(metric)
        elsif metric.is_a? Instruments::Timer
          print_timer(metric)
        end
      end
    end
    
    def print_gauge(gauge)
      @out.puts("    value = #{gauge.get}")
    end
    
    def print_counter(counter)
      @out.puts("    count = #{counter}")
    end
    
    def print_metered(meter)
      @out.puts("             count = #{meter.count}")
      @out.puts("         mean rate = #{meter.mean_rate}")
      @out.puts("     1-minute rate = #{meter.one_minute_rate}")
      @out.puts("     5-minute rate = #{meter.five_minute_rate}")
      @out.puts("    15-minute rate = #{meter.fifteen_minute_rate}")
    end
    
    def print_histogram(histogram)
      percentiles = histogram.quantiles([0.5, 0.75, 0.95, 0.98, 0.99, 0.999])
      @out.puts("               min = #{histogram.min}")
      @out.puts("               max = #{histogram.max}")
      @out.puts("              mean = #{histogram.mean}")
      @out.puts("            stddev = #{histogram.std_dev}") 
      percentiles.each do |name, percentile|
        @out.puts("          #{name} <= #{percentile}")  
      end
    end
    
    def print_timer(timer)
      print_metered(timer);
      percentiles = timer.quantiles([0.5, 0.75, 0.95, 0.98, 0.99, 0.999]);
      @out.puts("               min = #{timer.min}")
      @out.puts("               max = #{timer.max}") 
      @out.puts("              mean = #{timer.mean}") 
      @out.puts("            stddev = #{timer.std_dev}") 
      percentiles.each do |name, percentile|
        @out.puts("          #{name} <= #{percentile}")  
      end
    end
    
  end
end