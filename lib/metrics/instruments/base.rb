
module Metrics
  module Instruments
    class Base

      def initialize
      end
      
      def to_i
      end
      
      def to_s
        "override this"
      end
      
      def to_f
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
