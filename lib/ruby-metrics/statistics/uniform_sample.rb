module Metrics
  module Statistics
    class UniformSample
      def initialize(size = 1028)
        @values = Array.new(size)
        @size = size
        clear
      end

      def clear
        (0...@values.size).each do |i|
          @values[i] = 0
        end
        @count = 0
      end

      def size
        @values.size
      end

      def update(value)
        if @count < @values.length
          @values[@count] = value
          @count += 1
        else
          index = rand(@size) % @count
          @values[index] = value
        end
      end

      def values
        @values.dup
      end
    end
  end
end
