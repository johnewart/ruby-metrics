# Provides:
# * configurable agent
# * endpoint for accessing metrics JSON
# 
module Metrics
  module Integration
    module Rack
      class Endpoint
        
        attr_accessor :app, :options, :agent,
                      # integration metrics
                      :requests, :uncaught_exceptions,
                      :status_codes
        
        def initialize(options ={})
          @options  = options
          @agent    = @options.delete(:agent) || Agent.new
        end
        
        def call(_)
          body = @agent.to_json
          
          [ 200,
            { 'Content-Type'    => 'application/json',
              'Content-Length'  => body.size.to_s },
            [body]
          ]
        end
        
      end
    end
  end
end
