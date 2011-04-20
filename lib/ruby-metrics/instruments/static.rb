module Metrics
  module Instruments
    class Static < Base
      def initialize
        @data = {}
      end

      def []=(key, value)
        if value
          @data[key] = value
        else
          @data.delete(key)
        end
      end

      def [](key)
        @data[key]
      end

      def to_s
        @data.to_json
      end
    end
  end
end
