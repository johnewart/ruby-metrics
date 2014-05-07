
require 'rubygems'
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'ruby-metrics'
require 'ruby-metrics/reporters/opentsdb'

@metrics = Metrics::Agent.new
@hit_counter = 42
@http_counter = 53

def hit_count
  return 42 + rand(40)
end

def http_requests
  return 64 + rand(50)
end

gauge = @metrics.gauge :my_gauge do
  {
    :hit_count => hit_count,
    :http_requests => http_requests
  }
end

step = 0
meter = @metrics.meter :faults, 'faults'

puts "Gauge: #{gauge.to_s}"

result = gauge.get
counter = @metrics.counter :my_counter
counter.incr
counter.incr(50)

counter_two = @metrics.counter :counter_two
counter_two.incr(0)

timer = @metrics.timer :request_timer, 'requests'
puts "Result: #{result}"

Thread.new {
  begin
    modifier = rand(200).to_i
    step += 1

    if (step % 2)
      modifier *= -1
    end

    meter.mark(500  + modifier)
    puts "Sleeping for 0.53s --> #{meter.count}"
    sleep 0.53
  end while(true)
}

Thread.new {
  while(true)
    begin
      puts "TIMER1: #{timer.inspect}"
      timer.time do 
        sleeptime = rand(10) + 2
        puts "Sleeping for #{sleeptime}"
        sleep sleeptime
        true
      end
      puts "TIMER2: #{timer.inspect}"
    rescue => e
      puts "Error: #{e.inspect}"
    end
  end
}

opentsdb = Metrics::Reporters::OpenTSDBReporter.new({:hostname => 'localhost', :port => 4242, :agent => @metrics })
@metrics.report_to('opentsdb', opentsdb)
@metrics.report_periodically(3.26)
