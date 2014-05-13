module Metrics
  module Statistics
    class ExponentialSample
      RESCALE_WINDOW_SECONDS = 60 * 60 # 1 hour

      def initialize(size = 1028, alpha = 0.015)
        @size   = size
        @alpha  = alpha
        clear
      end
      
      def clear
        @values           = { }
        @start_time       = tick
        @next_scale_time  = Time.now.to_f + RESCALE_WINDOW_SECONDS
        @count            = 0
      end
      
      def size
        [@values.size, @count].min
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
        if @count <= @size
          @values[priority] = value
        else
          first_key = @values.keys.first
          if first_key && first_key < priority
            @values[priority] = value
            
            while values.any? && @values.delete(first_key).nil?
              first_key = @values.keys.first
            end
          end
        end
        
        now = Time.now.to_f

        if now >= @next_scale_time
          rescale(now + RESCALE_WINDOW_SECONDS)
        end
      end

      def values
        # read-lock?
        @values.keys.sort.map do |key|
          @values[key]
        end
      end

    private
      def rescale(next_scale_time)
        # writelock
        @next_scale_time = next_scale_time
        old_start_time = @start_time
        @start_time = tick
        time_delta = @start_time - old_start_time
        @values.keys.each do |key|
          value = @values.delete(key)
          new_key = key * Math.exp(-@alpha * time_delta)
          @values[new_key] = value
        end
        # unlock
      end
      
      def weight(factor)
        @alpha.to_f * factor.to_f
      end
    end
  end
end
