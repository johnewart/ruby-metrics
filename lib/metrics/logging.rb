require 'logger'

module Metrics
  module Logging
    
    def self.included(target)
      target.extend ClassMethods
    end
    
    def logger
      self.class.logger
    end
    
    module ClassMethods
      def logger
        Metrics.logger
      end
    end
    
  end
end
