require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'ruby-metrics'))

# Run with:
# ruby examples/integration/webrick.rb

@agent = Metrics::Agent.new

counter = @agent.counter(:my_counter)
counter.incr
counter.incr

Metrics::Integration::WEBrick.start(:port => 8001,
                                    :agent => @agent)

sleep
# Now navigate to: http://localhost:8001/stats
