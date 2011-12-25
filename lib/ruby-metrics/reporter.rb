module Metrics
  class Reporter
    # Default reporting delay is 60 seconds
    DEFAULT_REPORTING_DELAY = 60

    include Logging

    def initialize(options = {})

      if options[:agent] == nil
        raise "Need an agent to report data from"
      end

      if options[:service] == nil
        raise "Need a service to report to"
      end

      delay = options[:delay] || DEFAULT_REPORTING_DELAY
      agent = options[:agent] 
      service = options[:service]

      Thread.new {
        while(true)
          service.report(agent)
          sleep delay
        end
      }.join
    end

  end
end
