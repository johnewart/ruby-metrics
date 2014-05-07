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
        @tags = options[:tags] || {:units => 'none'}
      end

      def send_data(name, value, units = nil)
        tsdb_data = {
          :metric => name,
          :timestamp => Time.now.to_i,
          :value => value,
          :tags => @tags
        }

        if units
          tsdb_data[:tags][:units] = units
        end

        @client.put(tsdb_data)
      end

      def report(agent)
        agent.instruments.clone.each do |name, instrument|
          case instrument
            when Metrics::Instruments::Counter
              value = instrument.to_i
              send_data name, value
            when Metrics::Instruments::Gauge
              if instrument.get.is_a? Hash
                instrument.get.each do |key, value|
                  send_data "#{name}.#{key}", value
                end
              else 
                send_data name, instrument.get, instrument.units
              end
            when Metrics::Instruments::Timer
              rate_units = "sec/#{instrument.units}"
              time_units = "#{instrument.units}/sec"
              send_data "#{name}.count", instrument.count, instrument.units
              [:fifteen_minute_rate, :five_minute_rate, :one_minute_rate].each do |attribute|
                send_data "#{name}.#{attribute}", instrument.send(attribute), rate_units
              end

              [:min, :max, :mean].each do |attribute|
                send_data "#{name}.#{attribute}", instrument.send(attribute), time_units
              end
            when Metrics::Instruments::Meter
              rate_units = "#{instrument.units}/sec"
              send_data "#{name}.count", instrument.count, instrument.units
              [:fifteen_minute_rate, :five_minute_rate, :one_minute_rate, :mean_rate].each do |attribute|
                send_data "#{name}.#{attribute}", instrument.send(attribute), rate_units
              end
            else
              puts 'Unhandled instrument'
          end
        end
      end
    end
  end
end

