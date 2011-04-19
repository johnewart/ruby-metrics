module Metrics
  module Instruments
    class Calibration

      attr_accessor :duration_unit, :rate_unit

      def initialize
        @duration_unit = @rate_unit = :seconds
      end

    end
  end
end
