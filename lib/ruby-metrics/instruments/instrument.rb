module Metrics
  module Instruments
    class Instrument
      def tags
        @tags ||= {}
      end

      def tag(key, value)
        tags[key] = value
      end
    end
  end
end
