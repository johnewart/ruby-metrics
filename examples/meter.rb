require 'rubygems'
require '../lib/metrics'

@metrics = Metrics::Agent.new()
@metrics.start

timer = @metrics.add_instrument('meter', 'my_meter')
timer.mark(500)

step = 0

# This is here so that we will run indefinitely so you can hit the 
# status page on localhost:8001/status
loop { 
  sleep(1)
  modifier = rand(200).to_i
  step += 1
  
  if (step % 2)
    modifier *= -1
  end
  
  timer.mark(500  + modifier)
}