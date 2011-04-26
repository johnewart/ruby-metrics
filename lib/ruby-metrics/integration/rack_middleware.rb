# Provides:
# * configurable agent
# * configurable endpoint for current metrics
#   * strings == path_info
#   * regexp =~ path_info
#   * proc.call(env) #=> boolean
# * env['metrics.agent'] upstream
# * specific metrics by default
#   * requests (timer)
#   * uncaught_exceptions (counter)
#   * response_1xx through response_5xx (counter)
# 
module Metrics
  module Integration
    module Rack
      class Middleware
        
        attr_accessor :app, :options, :agent,
                      # integration metrics
                      :requests, :uncaught_exceptions,
                      :status_codes
        
        def initialize(app, options ={})
          @app      = app
          @options  = {:show => "/stats"}.merge(options)
          @agent    = @options.delete(:agent) || Agent.new
          
          # Integration Metrics
          @requests             = @agent.timer(:_requests)
          @uncaught_exceptions  = @agent.counter(:_uncaught_exceptions)
          
          # HTTP Status Codes
          @status_codes = {
            1 => @agent.counter(:_status_1xx),
            2 => @agent.counter(:_status_2xx),
            3 => @agent.counter(:_status_3xx),
            4 => @agent.counter(:_status_4xx),
            5 => @agent.counter(:_status_5xx)
          }
        end
        
        def call(env)
          return show(env) if show?(env)
          
          env['metrics.agent'] = @agent
          
          status, headers, body = self.requests.time{ @app.call(env) }
          
          if status_counter = self.status_codes[status / 100]
            status_counter.incr
          end
          
          [status, headers, body]
        rescue Exception
          # TODO: add "last_uncaught_exception" with string of error
          self.uncaught_exceptions.incr
          raise
        end
        
        def show?(env, test = self.options[:show])
          case
          when String === test;         env['PATH_INFO'] == test
          when Regexp === test;         env['PATH_INFO'] =~ test
          when test.respond_to?(:call); test.call(env)
          else                          test
          end
        end
        
        def show(_)
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
