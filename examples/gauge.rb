require 'rubygems'
require '../lib/ruby-metrics'

@metrics = Metrics::Agent.new
@metrics.start

hit_count = 42
http_requests = 53

gauge = @metrics.gauge :my_gauge do
  {
    :hit_count => hit_count,
    :http_requests => http_requests
  }
end

puts "Gauge: #{gauge.to_s}"

hit_count = 65
http_requests = 99

puts "Gauge: #{gauge.to_s}"

result = gauge.get

puts "Result: #{result}"
