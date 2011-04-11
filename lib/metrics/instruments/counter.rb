module Metrics
  module Instruments
    class Counter < Base
      
      def initialize
        @value = 0
      end
      
      def inc(value)
        @value += value
      end
      
      def dec(value)
        @value -= value
      end
      
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
