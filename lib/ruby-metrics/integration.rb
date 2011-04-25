module Metrics
  module Integration
    
    autoload :WEBrick, File.join(File.dirname(__FILE__), 'integration', 'webrick')
    
    module Rack
      autoload :Middleware, File.join(File.dirname(__FILE__), 'integration', 'rack_middleware')
      autoload :Endpoint,   File.join(File.dirname(__FILE__), 'integration', 'rack_endpoint')
    end
    
  end
end
