require 'rubygems' 
gem 'gmetric'
require 'gmetric'

result = Ganglia::GMetric.send("172.16.32.130", 8670, {
   :hostname => 'ook.unixninjas.org', 
   :spoof => 0,
   :name => 'narf',
   :units => 'reqs/sec',
   :type => 'uint8',
   :value => 7000,
   :tmax => 60,
   :dmax => 300,
})

puts "Result: #{result.inspect}"

