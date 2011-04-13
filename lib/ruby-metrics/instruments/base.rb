module Metrics
  module Instruments
    class Base
            
      def to_i
        raise NotImplementedError
      end
      
      def to_s
        raise NotImplementedError
      end
      
      def to_f
        raise NotImplementedError
      end

    end
  end
end
