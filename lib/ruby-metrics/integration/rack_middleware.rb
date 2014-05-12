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
        
        attr_accessor :app, :options, :agent

        def initialize(app, options ={})
          @app      = app
          @options  = {:show => "/stats"}.merge(options)
          @agent    = @options.delete(:agent) || Agent.new
        end

        def call(env)
          return show(env) if show?(env)
          
          env['metrics.agent'] = @agent
          
          status, headers, body = time_request { @app.call(env) }

          incr_status_code_counter(status / 100)

          [status, headers, body]
        rescue Exception
          # TODO: add "last_uncaught_exception" with string of error
          incr_uncaught_exceptions
          raise
        end

      private
        def show?(env, test = options[:show])
          case
          when String === test
            env['PATH_INFO'] == test
          when Regexp === test
            env['PATH_INFO'] =~ test
          when test.respond_to?(:call)
            test.call(env)
          else
            test
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

        def time_request(&block)
          @agent.timer(:_requests).time(&block)
        end

        def incr_uncaught_exceptions
          @agent.counter(:_uncaught_exceptions).incr
        end

        def incr_status_code_counter(hundred)
          @agent.counter(:"_status_#{hundred}xx").incr
        end
      end
    end
  end
end
