module Metrics
  module Statistics
    class UniformSample < Sample
      
      def initialize(size = 1028)
        @values = Array.new(size)
        @count = 0
        @size = size
        self.clear
      end
      
      def clear
        (0..@values.length-1).each do |i|
          @values[i] = 0
        end
        @count = 0
      end
      
      def size
        @values.length
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