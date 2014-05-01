require 'ruby-metrics'
require 'ruby-metrics/logging'
require 'opentsdb'

module Metrics
  module Reporters
    class OpenTSDBReporter

      include Logging

      attr_reader :hostname
      attr_reader :port
      attr_reader :client
      attr_reader :tags

      def initialize(options = {})
        @hostname = options[:hostname]
        @port = options[:port] 
        @client = OpenTSDB::Client.new({:hostname => @hostname, :port => @port})
        @tags = options[:tags] || {}
      end

      def send_data(data)
        tsdb_data = {
          :metric => data[:name],
          :timestamp => Time.now.to_i,
          :value => data[:value],
          :tags => data[:tags].merge(@tags)
        }
        logger.debug "Sending #{tsdb_data}"
        @client.put(tsdb_data)
      end

      def report(agent)

        agent.instruments.each do |name, instrument|
          nothing_to_do = false
          data =  { :name => name, :tags => { :units => instrument.units } }
          case instrument
            when Metrics::Instruments::Counter
              value = instrument.to_i
              data.merge! :value => value.to_i
              send_data data
            when Metrics::Instruments::Gauge
              if instrument.get.is_a? Hash
                instrument.get.each do |key, value|
                  data.merge! :name => "#{name}.#{key}", :value => value
                  send_data data
                end
              else 
                data.merge! :value => instrument.get
                send_data data
              end
            when Metrics::Instruments::Timer
              [:count, :fifteen_minute_rate, :five_minute_rate, :one_minute_rate, :min, :max, :mean].each do |attribute|
                data.merge!(:name => "#{name}.#{attribute}", :value => instrument.send(attribute))
                send_data data
              end
            when Metrics::Instruments::Meter
              [:count, :fifteen_minute_rate, :five_minute_rate, :one_minute_rate, :mean_rate].each do |attribute|
                data.merge!(:name => "#{name}.#{attribute}", :value => instrument.send(attribute) )
              end
            else 
              logger.error "Unhandled instrument"
          end
        end
      end
    end
  end
end

