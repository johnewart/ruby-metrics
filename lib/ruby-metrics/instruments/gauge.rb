module Metrics
  module Instruments
    class Gauge
      attr_reader :units

      def initialize(options = {}, &block)
        raise ArgumentError, "a block is required" unless block_given?
        @block = block
      end

      def get
        instance_exec(&@block)
      end

      def as_json(*_)
        value = get
        value.respond_to?(:as_json) ? value.as_json : value
      end

      def to_json(*_)
        as_json.to_json
      end
    end
  end
end
