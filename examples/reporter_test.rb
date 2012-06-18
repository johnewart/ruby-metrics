
require 'rubygems'
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'ruby-metrics'
require 'ruby-metrics/reporters/librato'
require 'ruby-metrics/reporters/ganglia'
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

puts "Gauge: #{gauge.to_s}"

result = gauge.get
=begin
counter = @metrics.counter :my_counter
counter.incr
counter.incr(50)

counter_two = @metrics.counter :counter_two
counter_two.incr(0)
=end 

timer = @metrics.timer :request_timer, "sec/req"
puts "Result: #{result}"
#librato = Metrics::Reporters::Librato.new({:user => "john@johnewart.net", :api_token => "a43c007db9fd073ac1005629fa937664ae20d02c1f45443ea900073e804f7ee7"})

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


#ganglia = Metrics::Reporters::GangliaReporter.new({:host_ip => "172.16.32.130", :host_port => 8670, :agent => @metrics})
opentsdb = Metrics::Reporters::OpenTSDBReporter.new({:hostname => 'localhost', :port => 4242, :agent => @metrics })
@metrics.report_to("opentsdb", {:service => opentsdb, :delay => 5})
