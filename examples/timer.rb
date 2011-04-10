require 'rubygems'
require '../lib/metrics'

@metrics = Metrics::Agent.new()
@metrics.start

timer = @metrics.add_instrument('timer', 'my_timer')
timer.mark(500)

step = 0

loop { 
  sleep(1)
  modifier = rand(200).to_i
  step += 1
  
  if (step % 2)
    modifier *= -1
  end
  
  timer.mark(500  + modifier)
}