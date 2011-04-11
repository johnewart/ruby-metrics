module Metrics
  module Instruments
    class Base
      include Logging
      
      def initialize
      end
      
      def to_i
      end
      
      def to_s
        "override this"
      end
      
      def to_f
      end
      
    end
  end
end
