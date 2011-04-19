module Metrics
  module Instruments
    class Calibration

      attr_accessor :duration_unit, :rate_unit

      def initialize
        @duration_unit = @rate_unit = :seconds
      end

      def calibrate(calibration)
        [:duration_unit, :rate_unit].each do |parameter|
          if calibration.respond_to?(parameter)
            writer = parameter.to_s + '='
            value = calibration.send(parameter)
            self.send(writer, value)
          end
        end
      end

    end
  end
end
