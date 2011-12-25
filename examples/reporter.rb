
require 'rubygems'
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'ruby-metrics'
require 'ruby-metrics/reporters/librato'

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

puts "Gauge: #{gauge.to_s}"

result = gauge.get
=begin
counter = @metrics.counter :my_counter
counter.incr
counter.incr(50)

counter_two = @metrics.counter :counter_two
counter_two.incr(0)
=end 

timer = @metrics.timer :request_timer
puts "Result: #{result}"
librato = Metrics::Reporters::Librato.new({:user => "john@johnewart.net", :api_token => "a43c007db9fd073ac1005629fa937664ae20d02c1f45443ea900073e804f7ee7"})


Thread.new {
  while(true)
    begin
      #counter.incr(sleeptime)
      #counter_two.incr(sleeptime)
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


@metrics.report_to("librato", {:service => librato, :delay => 5})
