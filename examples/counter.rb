require 'rubygems'
require '../lib/metrics'

@metrics = Metrics::Agent.new
@metrics.start

counter = @metrics.add_instrument('counter', 'my_counter')
counter.inc(1)
counter.inc(1)

puts "Counter: #{counter.to_i}"
