require 'rubygems'
require '../lib/ruby-metrics/integration/webrick'

@metrics = Metrics::Agent.new
@metrics.start :port => 8081 # optional

timer = @metrics.timer :my_timer
timer.update(500,   :milliseconds)
timer.update(5,     :seconds)
timer.update(4242,  :nanoseconds)

msec_timer = @metrics.timer :msec_timer, {:duration_unit => :microseconds, :rate_unit => :seconds}

step = 0

# This is here so that we will run indefinitely so you can hit the 
# status page on localhost:8081/stats
loop do
  sleep 1
  
  modifier = rand(200).to_i
  step += 1
  
  if (step % 2)
    modifier *= -1
  end
  
  timer.update(500  + modifier, :microseconds)
  msec_timer.update(500 + modifier, :microseconds)

end
