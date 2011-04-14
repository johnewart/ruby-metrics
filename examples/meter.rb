require 'rubygems'
require '../lib/ruby-metrics'

# Specify a port for the agent
@metrics = Metrics::Agent.new(8081)
@metrics.start

timer = @metrics.meter :my_meter
timer.mark(500)

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
  
  timer.mark(500  + modifier)
end
