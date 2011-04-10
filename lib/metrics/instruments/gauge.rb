
module Metrics
  module Instruments
    class Gauge < Base

      def initialize(block)
        @block = block
      end
      
      def get
        instance_exec(&@block)
      end
      
      def to_s
        instance_exec(&@block).to_json
      end
      
    end
  end
end
