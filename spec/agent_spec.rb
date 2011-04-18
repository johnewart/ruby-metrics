require 'spec_helper.rb'

describe Metrics::Agent do

  let(:logger) { double(:logger) }

  before(:each) do
    Metrics::Agent.stub!(:logger).and_return(logger)
    logger.stub!(:debug).and_return('') # quiet logging for the soul
  end

  describe '#new' do

    context 'with no arguments' do

      it 'should bind to port 8001' do
        subject.port.should eql(8001)
      end

    end

    context 'with a port number' do

      subject { Metrics::Agent.new(8010) }

      it 'should bind to the given port' do
        subject.port.should eql(8010)
      end

    end

  end

  describe '#start' do
    
    it 'should start up a daemon thread' do
      subject.should_receive(:start_daemon_thread)
      subject.start
    end

  end

  Metrics::Instruments.types.each do |instrument, instrument_class|

    describe "##{instrument}" do

      context 'given a name and a block' do

        let(:name) { ('test_'+instrument.to_s).to_sym }
        let(:block) { Proc.new { :block } }

        it "should return a new #{instrument_class}" do
          subject.public_send(instrument, name, &block).
            should be_a(instrument_class)
        end

        it "should register a new #{instrument_class} under the given name" do
          test_instrument = double(instrument_class)
          instrument_class.stub!(:new).and_return(test_instrument)

          subject.public_send(instrument, name, &block)
          subject.instruments.registered[name].should eql(test_instrument)
        end

      end

    end

  end

  describe '#start_daemon_thread' do

    let(:mock_server) { mock(WEBrick::HTTPServer) }

    before do
      Thread.stub!(:new).and_return do |block|
        block.call
      end
    end

    context 'when WEBrick behaves' do

      before do
        WEBrick::HTTPServer.should_receive(:new).and_return mock_server
      end
      
      it "should start and mount the WEBrick daemon" do
        mock_server.should_receive(:mount)
        mock_server.should_receive(:start)
        subject.start
      end

    end

    context 'when WEBrick throws an error' do

      before do
        WEBrick::HTTPServer.should_receive(:new).and_throw(Exception)
      end

      it 'should log the error' do
        logger.should_receive(:error)
        subject.start
      end

    end

  end

end
