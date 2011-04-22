module Metrics
  module Instruments
    class Heartbeat < Base
      
      def initialize
        @value = nil 
      end
      
      def last
        @value
      end

      def beat
        @value = Time.now() 
      end

      alias_method :go, :beat
      alias_method :pulse, :beat 

      def to_i
        @value.to_i
      end
      
      def to_s
        @value.to_s
      end
      
    end
  end
end
