require 'rubygems'
require '../lib/ruby-metrics'

# Specify a port for the agent
@metrics = Metrics::Agent.new(8081)
@metrics.start

timer = @metrics.timer :my_timer
timer.update(500,   :milliseconds)
timer.update(5,     :seconds)
timer.update(4242,  :nanoseconds)

msec_timer = @metrics.timer :msec_timer do |t| 
  t.duration_unit = :microseconds
  t.rate_unit = :seconds
end

step = 0

# This is here so that we will run indefinitely so you can hit the 
# status page on localhost:8081/status
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
