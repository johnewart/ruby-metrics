module Metrics
  module Instruments
    class Gauge
      def initialize(&block)
        raise ArgumentError, "a block is required" unless block_given?
        @block = block
      end

      def get
        instance_exec(&@block)
      end

      def to_json(*_)
        value = get
        value.respond_to?(:to_json) ? value.to_json : value
      end
    end
  end
end
