require 'spec_helper.rb'

describe Metrics::Agent do
  before :each do 
    @agent = Metrics::Agent.new
  end
  
  it "should create a new agent" do  
  end
  
  it "should add a counter instrument correctly" do 
    @counter = Metrics::Instruments::Counter.new
    Metrics::Instruments::Counter.stub!(:new).and_return @counter
    @agent.counter(:test_counter).should == @counter
  end
  
  it "should allow for creating a gauge with a block via #gauge" do 
    @agent.gauge :test_gauge do 
      "result"
    end
  end
  
  it "should add a meter instrument correctly" do
    @meter = Metrics::Instruments::Meter.new
    Metrics::Instruments::Meter.stub!(:new).and_return @meter

    @agent.meter(:test_meter).should == @meter
  end
  
  it "should start the WEBrick daemon" do
    Thread.stub!(:new).and_return do |block|
      block.call
    end
    
    mock_server = mock(WEBrick::HTTPServer)
    WEBrick::HTTPServer.should_receive(:new).and_return mock_server
    mock_server.should_receive(:mount)
    mock_server.should_receive(:start)
    @agent.start
  end
    
end