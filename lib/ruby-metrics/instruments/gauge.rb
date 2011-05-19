module Metrics
  module Instruments
    class Gauge < Base
      
      def initialize(&block)
        raise ArgumentError, "a block is required" unless block_given?
        @block = block
      end
      
      def get
        instance_exec(&@block)
      end
      
      def to_json(*_)
        get.to_json
      end
      
    end

    register_instrument(:gauge, Gauge)
  end
end
