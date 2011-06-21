module Metrics
  module Statistics
    class ExponentialSample
      def initialize(size = 1028, alpha = 0.015)
        @values = Hash.new
        @count  = 0
        @size   = size
        @alpha  = alpha
        @rescale_window = 3600  #seconds -- 1 hour
        self.clear
      end
      
      def clear
        @values           = Hash.new
        @start_time       = tick
        @next_scale_time  = Time.now.to_f + @rescale_window
        @count            = 0
      end
      
      def size
        [@values.keys.length, @count].min
      end
      
      def tick
        Time.now.to_f
      end
      
      def update(value)
        update_with_timestamp(value, tick)
      end
      
      def update_with_timestamp(value, timestamp)
        priority = weight(timestamp.to_f - @start_time.to_f) / rand
        @count += 1
        newcount = @count
        if (newcount <= @size)
          @values[priority] = value
        else
          firstkey = @values.keys[0]
          if (firstkey < priority)
            @values[priority] = value
            
            while(@values.delete(firstkey) == nil)
              firstkey = @values.keys[0]
            end
          end
        end
        
        now = Time.now.to_f
        next_scale_time = @next_scale_time
        
        if (now >= next_scale_time)
          self.rescale(now, next_scale_time)
        end
      end
      
      
      def rescale(now, next_scale_time)
        if @next_scale_time == next_scale_time
          # writelock
          @next_scale_time = now + @rescale_window
          old_start_time = @start_time
          @start_time = tick
          time_delta = @start_time - old_start_time
          keys = @values.keys
          keys.each do |key|
            value = @values.delete(key)
            new_key = (key * Math.exp(-@alpha * time_delta))
            @values[new_key] = value
          end
          # unlock
        end  
      end
      
      def weight(factor)
        return @alpha.to_f * factor.to_f
      end
      
      def values
        # read-lock?
        result = Array.new
        keys = @values.keys.sort
        keys.each do |key|
          result << @values[key]
        end
        
        result
      end
    end
  end
end
