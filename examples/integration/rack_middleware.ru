require 'rubygems'

# Ran with:
# rackup -p 8000 ./examples/integration/rack_middleware.ru
# 
# Make requests to: http://localhost:8000/
# See stats at    : http://localhost:8000/stats

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'ruby-metrics')
@agent = Metrics::Agent.new

counter = @agent.counter(:my_counter)

use Metrics::Integration::Rack::Middleware, :agent => @agent

app = proc do |env|
  counter.incr
  [200, {'Content-Type' => 'text/plain'}, ["Counted!"]]
end

run app
