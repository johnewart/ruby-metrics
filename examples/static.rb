require 'rubygems'
require '../lib/ruby-metrics'

# Specify a port for the agent
@metrics = Metrics::Agent.new(8081)
@metrics.start

static = @metrics.static(:data)
static[:start_time] = Time.now
static[:status] = :OK
static[:step] = 0

step = 0

# This is here so that we will run indefinitely so you can hit the 
# status page on localhost:8081/status
loop do
  sleep 1

  static[:step] = step
  static[:status] = :CRITICAL if step > 10
  
  step += 1
end
