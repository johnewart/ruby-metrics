require 'rubygems'
require '../lib/metrics'

@metrics = Metrics::Agent.new
@metrics.start

counter = @metrics.counter :my_counter
counter.incr
counter.incr

puts "Counter: #{counter.to_i}"
