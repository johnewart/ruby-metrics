module Metrics
  module Integration
    
    autoload :WEBrick, File.expand_path('../integration/webrick', __FILE__)
    
    module Rack
      autoload :Middleware, File.expand_path('../integration/rack_middleware', __FILE__)
      autoload :Endpoint,   File.expand_path('../integration/rack_endpoint', __FILE__)
    end
  end
end
