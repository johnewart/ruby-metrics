require 'ruby-metrics/version'
require 'ruby-metrics'

require 'gmetric'

module Metrics
  module Reporters
    class GangliaReporter

      attr_reader :host_ip, :host_port

      def initialize(options = {})
        @host_ip = options[:host_ip]
        @host_port = options[:host_port] 
      end

      def send_data(data)
        puts "Sending data: #{data.inspect}"
        data_type =
          case data[:value]
          Fixnum
            "uint32"
          Float
            "float"
          String
            "string"
          else
            "unknown"
          end

        Ganglia::GMetric.send(@host_ip, @host_port.to_i,
           :spoof => 0,
           :name => data[:name],
           :units => data[:units],
           :type => data_type,
           :value => data[:value],
           :tmax => 60,
           :dmax => 300,
        )
      end

      def report(agent)
        agent.instruments.each do |name, instrument|
          case instrument
          when Metrics::Instruments::Counter
            send_data :name  => name,
                      :value => instrument.to_i,
                      :units => instrument.units
          when Metrics::Instruments::Gauge
            if instrument.get.is_a? Hash
              instrument.get.each do |key, value|
                send_data :name  => "#{name}_#{key}",
                          :value => value,
                          :units => instrument.units
              end
            else
              send_data :name  => name,
                        :value => instrument.get,
                        :units => instrument.units
            end
          when Metrics::Instruments::Timer
            [:count, :fifteen_minute_rate, :five_minute_rate, :one_minute_rate, :min, :max, :mean].each do |attribute|
              send_data :name  => "#{name}_#{attribute}",
                        :value => instrument.send(attribute),
                        :units => instrument.units
            end
          when Metrics::Instruments::Meter
            [:count, :fifteen_minute_rate, :five_minute_rate, :one_minute_rate, :mean_rate].each do |attribute|
              send_data :name  => "#{name_attribute}",
                        :value => instrument.send(attribute),
                        :units => instrument.units
            end
          else
            puts "Unhandled instrument"
          end
        end
      end
    end
  end
end
