module Metrics
  module Instruments
    class Counter < Base
      
      def initialize
        @counter_value = 0
      end
      
      def inc (value)
        @counter_value += value
        @counter_value
      end
      
      def dec (value)
        @counter_value -= value
        @counter_value
      end
      
      def clear
        @counter_value = 0
      end
      
      def to_i
        @counter_value.to_i
      end
      
      def to_s
        @counter_value.to_s
      end
      
    end
  end
end
