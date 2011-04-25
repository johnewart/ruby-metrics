require File.join(File.dirname(__FILE__), 'logging')
require File.join(File.dirname(__FILE__), 'instruments')
require File.join(File.dirname(__FILE__), 'integration')

module Metrics
  class Agent
    include Logging
    include Instruments::TypeMethods
    
    attr_reader :instruments
    
    def initialize
      logger.debug "Initializing Metrics..."
      @instruments = Metrics::Instruments
    end
    
    def to_json
      @instruments.to_json
    end
    
  end
end
