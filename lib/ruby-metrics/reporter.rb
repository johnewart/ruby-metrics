module Metrics
  class Reporter
    # Default reporting delay is 60 seconds
    DEFAULT_REPORTING_DELAY = 60

    include Logging

    def stop
      @running = false
    end

    def initialize(options = {})
      @running = true

      if options[:agent] == nil
        raise "Need an agent to report data from"
      end

      delay = options[:delay] || DEFAULT_REPORTING_DELAY
      agent = options[:agent] 

      Thread.new {
        while(@running)
          agent.reporters.each do |name, service|
            service.report(agent)
          end
          sleep delay
        end
      }
    end

  end
end
