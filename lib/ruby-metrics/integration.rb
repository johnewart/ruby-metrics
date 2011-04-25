module Metrics
  module Integration
    
    module Rack
      autoload :Middleware, File.join(File.dirname(__FILE__), 'integration', 'rack_middleware')
      autoload :Endpoint,   File.join(File.dirname(__FILE__), 'integration', 'rack_endpoint')
    end
    
  end
end
