require 'ruby-metrics/agent'
require 'ruby-metrics/reporter'
require 'ruby-metrics/reporters/opentsdb'

module Metrics
  describe 'Reporter' do
    let(:mock_reporter) {
      double(Metrics::Reporters::OpenTSDBReporter)
    }

    let(:agent) {
      agent = Metrics::Agent.new
      agent.report_to 'opentsdb', mock_reporter
      agent
    }

    it 'should report three times in 4 seconds with a 1 second interval' do
      expect(mock_reporter).to receive(:report).exactly(3).times
      agent.report_periodically(1)
      puts "Sleeping"
      sleep(4)
      puts "Stopping..."
      agent.stop_reporting
    end

  end
end
