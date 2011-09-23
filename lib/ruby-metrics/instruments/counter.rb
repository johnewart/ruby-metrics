module Metrics
  module Instruments
    class Counter
      def initialize
        @value = 0
      end
      
      def inc(value = 1)
        @value += value
      end
      alias_method :incr, :inc
      
      def dec(value = 1)
        @value -= value
      end
      alias_method :decr, :dec
      
      def clear
        @value = 0
      end
      
      def to_i
        @value.to_i
      end
      
      def to_s
        @value.to_s
      end

      def as_json(*_)
        @value
      end
      
      def to_json(*_)
        as_json.to_json
      end
    end
  end
end
