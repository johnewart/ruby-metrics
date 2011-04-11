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
      
      def logger
        self.class.logger
      end
      
      class << self
        def logger
          @logger ||= Logger.new(STDOUT)
        end
      end
    end
  end
end
