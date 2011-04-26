require 'rubygems'

# Ran with:
# rackup -p 8000 ./examples/integration/rack_endpoint.ru
# 
# Make requests to: http://localhost:8000/
# See stats at    : http://localhost:8000/stats

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'ruby-metrics')
@agent = Metrics::Agent.new

counter = @agent.counter(:my_counter)

app = proc do |env|
  counter.incr
  [200, {'Content-Type' => 'text/plain'}, ["Counted!"]]
end

map = Rack::URLMap.new({
  '/stats'  => Metrics::Integration::Rack::Endpoint.new(:agent => @app),
  '/'       => app
})

run map
