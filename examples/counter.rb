require 'rubygems'
require '../lib/ruby-metrics'

@metrics = Metrics::Agent.new

counter = @metrics.counter :my_counter
counter.incr
counter.incr

puts "Counter: #{counter.to_i}"
