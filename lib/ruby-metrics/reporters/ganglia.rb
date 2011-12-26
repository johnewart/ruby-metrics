require 'ruby-metrics/version'
require 'ruby-metrics'

require 'gmetric'

module Metrics
  module Reporters
    class GangliaReporter
      attr_reader :host_ip
      attr_reader :host_port

      def initialize(options = {})
        @host_ip = options[:host_ip]
        @host_port = options[:host_port] 
      end

      def send_data(data)
        puts "Sending data: #{data.inspect}"
        data_type = case data[:value].class.to_s
                    when "Fixnum"
                      "uint32"
                    when "Float"
                      "float"
                    when "String"
                      "string"
                    else
                      "whosawhatsa"
                    end
        puts "Datatype: #{data_type}"
        Ganglia::GMetric.send(@host_ip, @host_port.to_i, {
           :spoof => 0,
           :name => data[:name],
           :units => data[:units],
           :type => data_type,
           :value => data[:value],
           :tmax => 60,
           :dmax => 300,
        })
      end

      def report(agent)

        agent.instruments.each do |name, instrument|
          nothing_to_do = false
          data =  { :name => name, :units => instrument.units }
          case instrument.class.to_s
            when "Metrics::Instruments::Counter"
              value = instrument.to_i
              data.merge! :value => value.to_i
              send_data data
            when "Metrics::Instruments::Gauge"
              if instrument.get.is_a? Hash
                instrument.get.each do |key, value|
                  data.merge! :name => "#{name}_#{key}", :value => value
                  send_data data
                end
              else 
                data.merge! :value => instrument.get
                send_data data
              end
            when "Metrics::Instruments::Timer"
              [:count, :fifteen_minute_rate, :five_minute_rate, :one_minute_rate, :min, :max, :mean].each do |attribute|
                data.merge!(:name => "#{name}_#{attribute}", :value => instrument.send(attribute))
                send_data data
              end
            else 
              puts "Unhandled instrument"
          end
        end
      end
    end
  end
end

