module Metrics
  module Statistics
    class Sample
	    def clear
	      raise NotImplementedError
	    end
	    
	    def size
	      raise NotImplementedError
      end
      
      def update(value)
        raise NotImplementedError
      end
      
      def values
        raise NotImplementedError
      end
    end
  end
end