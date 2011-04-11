require File.join(File.dirname(__FILE__), 'logging')
require File.join(File.dirname(__FILE__), 'instruments')
require 'webrick'

class Status < WEBrick::HTTPServlet::AbstractServlet
  
  def initialize(server, instruments)
    @instruments = instruments
  end
  
  def do_GET(request, response)
    status, content_type, body = do_stuff_with(request)
    
    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end
  
  def do_stuff_with(request)
    return 200, "text/plain", @instruments.to_json
  end
  
end

module Metrics
  class Agent
    include Logging
    
    attr_reader :instruments
    
    def initialize()
      logger.debug "Initializing Metrics..."
      @instruments = Metrics::Instruments
    end
    
    def add_instrument(type, name, &block)
      if block_given?
        @instruments.register(type, name, block)
      else
        @instruments.register(type, name)
      end
    end
    
    def start
      start_daemon_thread
    end
    
    protected
    def start_daemon_thread(connection_options = {})
      logger.debug "Creating Metrics worker thread."
      @daemon_thread = Thread.new do
        begin
          server = WEBrick::HTTPServer.new ({:Port => 8001})
          server.mount "/status", Status, @instruments
          server.start
        rescue Exception => e
          logger.error "Error in worker thread: #{e.class.name}: #{e}\n  #{e.backtrace.join("\n  ")}"
        end # begin
      end # thread new
    end
  end
end
