module Metrics
  module Integration
    
    module Rack
      autoload :Middleware, File.join(File.dirname(__FILE__), 'integration', 'rack_middleware')
    end
    
  end
end
