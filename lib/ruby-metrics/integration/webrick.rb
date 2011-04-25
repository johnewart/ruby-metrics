require 'webrick'

module Metrics
  module Integration
    class WEBrick < ::WEBrick::HTTPServlet::AbstractServlet
      include Logging
      
      def self.start(options = {})
        connection_options = {:Port => options.delete(:port) || options.delete(:Port) || 8001}
        agent = options.delete(:agent) || Agent.new
        
        logger.debug "Creating Metrics daemon thread."
        @thread = Thread.new do
          begin
            server = ::WEBrick::HTTPServer.new(connection_options)
            server.mount "/stats", self, agent
            server.start
          rescue Exception => e
            logger.error "Error in thread: %s: %s\n\t%s" % [e.class.to_s,
                                                            e.message,
                                                            e.backtrace.join("\n\t")]
          end
        end
      end
      
      def initialize(server, agent)
        @agent = agent
      end
      
      def do_GET(request, response)
        response.status           = 200
        response['Content-Type']  = 'application/json'
        response.body             = @agent.to_json
      end
      
    end
  end
end
