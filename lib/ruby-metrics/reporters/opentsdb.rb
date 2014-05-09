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
        @tags = options[:tags]
      end

      def send_data(opts = {})
        name = opts[:name]
        value = opts[:value]
        units = opts[:units]
        extra_tags = opts[:tags]

        tsdb_data = {
          :metric => name,
          :timestamp => Time.now.to_i,
          :value => value,
          :tags => @tags
        }

        if units
          tsdb_data[:tags][:units] = units
        else
          tsdb_data[:tags][:units] = 'none'
        end

        if extra_tags
          tsdb_data[:tags].merge!(extra_tags)
        end

        @client.put(tsdb_data)
      end

      def report(agent)
        agent.instruments.clone.each do |name, instrument|
          case instrument
            when Metrics::Instruments::Counter
              send_data :name  => "#{name}",
                        :value => instrument.to_i,
                        :tags  => instrument.tags,
                        :units => instrument.units

            when Metrics::Instruments::Gauge
              if instrument.get.is_a? Hash
                instrument.get.each do |key, value|
                  send_data :name  => "#{name}.#{key}",
                            :value => value,
                            :tags  => instrument.tags,
                            :units => instrument.units
                end
              else 
                send_data :name  => "#{name}",
                          :value => instrument.get,
                          :tags  => instrument.tags,
                          :units => instrument.units
              end
            when Metrics::Instruments::Timer
              rate_units = "#{instrument.units}/sec"
              time_units = "sec/#{instrument.units}"

              send_data :name  => "#{name}.count",
                        :value => instrument.count,
                        :tags  => instrument.tags,
                        :units => instrument.units

              [:fifteen_minute_rate, :five_minute_rate, :one_minute_rate].each do |attribute|
                send_data :name  => "#{name}.#{attribute}",
                          :value => instrument.send(attribute),
                          :tags  => instrument.tags,
                          :units => rate_units
              end

              [:min, :max, :mean].each do |attribute|
                send_data :name  => "#{name}.#{attribute}",
                          :value => instrument.send(attribute),
                          :tags  => instrument.tags,
                          :units => time_units
              end
            when Metrics::Instruments::Meter
              send_data :name  => "#{name}.count",
                        :value => instrument.counted,
                        :tags  => instrument.tags,
                        :units => instrument.units

              rate_units = "#{instrument.units}/sec"
              [:fifteen_minute_rate, :five_minute_rate, :one_minute_rate, :mean_rate].each do |attribute|
                send_data :name  => "#{name}.#{attribute}",
                          :value => instrument.send(attribute),
                          :tags  => instrument.tags,
                          :units => rate_units
              end
            else
              puts 'Unhandled instrument'
          end
        end
      end
    end
  end
end

