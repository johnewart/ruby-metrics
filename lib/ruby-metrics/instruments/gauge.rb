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
      
      def as_json(*_)
        get
      end
      
    end

    register_instrument(:gauge, Gauge)
  end
end
