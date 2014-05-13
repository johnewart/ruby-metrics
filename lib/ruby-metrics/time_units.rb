module Metrics

  module Nanoseconds
    def self.to_nsec(mult = 1)
      mult
    end
  end
  
  module Microseconds
    def self.to_nsec(mult = 1)
      1000 * mult
    end
  end
  
  module Milliseconds
    def self.to_nsec(mult = 1)
      1000000 * mult
    end
  end
  
  module Seconds
    def self.to_nsec(mult = 1)
      1000000000 * mult
    end
  end
  
  module Minutes
    def self.to_nsec(mult = 1)
      60000000000 * mult
    end
  end
  
  module Hours
    def self.to_nsec(mult = 1)
      3600000000000 * mult
    end
  end
  
  module TimeConversion
    UNITS = {
        :nanoseconds            => Nanoseconds,
        :microseconds           => Microseconds,
        :milliseconds           => Milliseconds,
        :seconds                => Seconds,
        :minutes                => Minutes,
        :hours                  => Hours
    }
  
    def convert_to_ns(value, unit)
      UNITS[unit].to_nsec.to_f * value.to_f
    end

    def scale_time_units(source, dest)
      UNITS[source].to_nsec.to_f / UNITS[dest].to_nsec.to_f
    end
  end
end
