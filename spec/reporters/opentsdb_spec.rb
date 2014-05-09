require 'spec_helper'
require 'opentsdb/client'
require 'ruby-metrics/reporters/opentsdb'
require 'ruby-metrics'
require 'timecop'

module Metrics
  module Reporters
    describe 'OpenTSDBReporter' do

      let(:mock_tsdb_client) {
        mock_tsdb_client = double(OpenTSDB::Client)
      }

      let(:reporter) {
        expect(OpenTSDB::Client).to receive(:new).and_return mock_tsdb_client
        OpenTSDBReporter.new(:tags => {:foo => 'bar'})
      }

      let(:agent) {
        Metrics::Agent.new
      }

      it 'should report a counter correctly' do
        counter = agent.counter :my_counter
        counter.incr
        counter.incr

        counter_data = {
            :value => 2,
            :timestamp => anything,
            :tags => {
                :units => '',
                :foo => 'bar'
            },
            :metric => 'my_counter'
        }
        expect(mock_tsdb_client).to receive(:put).with(counter_data)

        reporter.report(agent)
      end

      it 'should report a tagged counter correctly' do
        counter = agent.counter :logins, 'logins'
        counter.incr
        counter.tag(:user, 'sam')

        counter_data = {
            :value => 1,
            :timestamp => anything,
            :tags => {
                :units => 'logins',
                :foo => 'bar',
                :user => 'sam'
            },
            :metric => 'logins'
        }
        expect(mock_tsdb_client).to receive(:put).with(counter_data)

        reporter.report(agent)
      end

      it 'should report a gauge that returns a hash' do
        gauge = agent.gauge :my_gauge do
          {
              :hit_count => 42,
              :http_requests => 320
          }
        end
        gauge.tag(:mytag, 'somevalue')


        tags = {
            :units => '',
            :foo => 'bar',
            :mytag => 'somevalue'
        }

        gauge_hit_data = {
            :value => 42,
            :timestamp => anything,
            :tags => tags,
            :metric => 'my_gauge.hit_count'
        }
        gauge_requests_data = {
            :value => 320,
            :timestamp => anything,
            :tags => tags,
            :metric => 'my_gauge.http_requests'
        }
        expect(mock_tsdb_client).to receive(:put).with(gauge_hit_data)
        expect(mock_tsdb_client).to receive(:put).with(gauge_requests_data)

        reporter.report(agent)
      end


      it 'should report a gauge that returns a non-hash value' do
        agent.gauge :boring_gauge, 'units' do
          42
        end

        gauge_data = {
            :value => 42,
            :timestamp => anything,
            :tags => {
                :units => 'units',
                :foo => 'bar',
            },
            :metric => 'boring_gauge'
        }
        expect(mock_tsdb_client).to receive(:put).with(gauge_data)

        reporter.report(agent)
      end

      it 'should report a timer' do
        timer = agent.timer :some_timer, 'requests'
        timer.update(5, :seconds)

        timer_counter_data = {
            :value => 1,
            :timestamp => anything,
            :tags => {
                :units => 'requests',
                :foo => 'bar'
            },
            :metric => 'some_timer.count'
        }
        expect(mock_tsdb_client).to receive(:put).with(timer_counter_data)

        timer_fifteen = {
            :value => 0.0,
            :timestamp => anything,
            :tags => {
                :units => 'requests/sec',
                :foo => 'bar'
            },
            :metric => 'some_timer.fifteen_minute_rate'
        }
        expect(mock_tsdb_client).to receive(:put).with(timer_fifteen)

        timer_five = {
            :value => 0.0,
            :timestamp => anything,
            :tags => {
                :units => 'requests/sec',
                :foo => 'bar'
            },
            :metric => 'some_timer.five_minute_rate'
        }
        expect(mock_tsdb_client).to receive(:put).with(timer_five)


        timer_one = {
            :value => 0.0,
            :timestamp => anything,
            :tags => {
                :units => 'requests/sec',
                :foo => 'bar'
            },
            :metric => 'some_timer.one_minute_rate'
        }
        expect(mock_tsdb_client).to receive(:put).with(timer_one)


        timer_min = {
            :value => 5.0,
            :timestamp => anything,
            :tags => {
                :units => 'sec/requests',
                :foo => 'bar'
            },
            :metric => 'some_timer.min'
        }
        expect(mock_tsdb_client).to receive(:put).with(timer_min)


        timer_max = {
            :value => 5.0,
            :timestamp => anything,
            :tags => {
                :units => 'sec/requests',
                :foo => 'bar'
            },
            :metric => 'some_timer.max'
        }
        expect(mock_tsdb_client).to receive(:put).with(timer_max)

        timer_mean = {
            :value => 5.0,
            :timestamp => anything,
            :tags => {
                :units => 'sec/requests',
                :foo => 'bar'
            },
            :metric => 'some_timer.mean'
        }
        expect(mock_tsdb_client).to receive(:put).with(timer_mean)

        reporter.report(agent)
      end

      it 'should report a gauge that returns a non-hash value' do
        agent.gauge :boring_gauge, 'units' do
          42
        end

        gauge_data = {
            :value => 42,
            :timestamp => anything,
            :tags => {
                :units => 'units',
                :foo => 'bar',
            },
            :metric => 'boring_gauge'
        }
        expect(mock_tsdb_client).to receive(:put).with(gauge_data)

        reporter.report(agent)
      end

      it 'should report a meter' do
        expect(Thread).to receive(:new).and_return nil

        meter = agent.meter :http_requests, 'requests'
        meter.mark
        meter.mark
        meter.mark
        meter.tick
        meter.mark
        meter.tag :somekey, 'value'

        meter_counter_data = {
            :value => 1,
            :timestamp => anything,
            :tags => {
                :units => 'requests',
                :foo => 'bar',
                :somekey => 'value'
            },
            :metric => 'http_requests.count'
        }
        expect(mock_tsdb_client).to receive(:put).with(meter_counter_data)

        meter_fifteen = {
            :value => 0.6,
            :timestamp => anything,
            :tags => {
                :units => 'requests/sec',
                :foo => 'bar',
                :somekey => 'value'
            },
            :metric => 'http_requests.fifteen_minute_rate'
        }
        expect(mock_tsdb_client).to receive(:put).with(meter_fifteen)

        meter_five = {
            :value => 0.6,
            :timestamp => anything,
            :tags => {
                :units => 'requests/sec',
                :foo => 'bar',
                :somekey => 'value'
            },
            :metric => 'http_requests.five_minute_rate'
        }
        expect(mock_tsdb_client).to receive(:put).with(meter_five)


        meter_one = {
            :value => 0.6,
            :timestamp => anything,
            :tags => {
                :units => 'requests/sec',
                :foo => 'bar',
                :somekey => 'value'
            },
            :metric => 'http_requests.one_minute_rate'
        }
        expect(mock_tsdb_client).to receive(:put).with(meter_one)

        meter_mean = {
            :value => anything,
            :timestamp => anything,
            :tags => {
                :units => 'requests/sec',
                :foo => 'bar',
                :somekey => 'value'
            },
            :metric => 'http_requests.mean_rate'
        }
        expect(mock_tsdb_client).to receive(:put).with(meter_mean)

        reporter.report(agent)
      end
    end
  end
end
