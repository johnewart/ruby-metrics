module Metrics
  module Instruments
    class Counter < Base
      
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
      
    end
  end
end
