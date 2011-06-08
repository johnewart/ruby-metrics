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
  
  it "should add a Histogram instrument using uniform sampling" do
    histogram = Metrics::Instruments::UniformHistogram.new
    Metrics::Instruments::UniformHistogram.stub!(:new).and_return histogram
    @agent.uniform_histogram(:test_histogram).should == histogram
  end

  it "should allow for registering a Histogram instrument using exponentially decaying sampling" do
    histogram = Metrics::Instruments::ExponentialHistogram.new
    Metrics::Instruments::ExponentialHistogram.stub!(:new).and_return histogram
    @agent.exponential_histogram(:test_histogram).should == histogram
  end  

  it "should set up a histogram using uniform distribution if just a histogram is registered" do
    histogram = Metrics::Instruments::UniformHistogram.new
    Metrics::Instruments::UniformHistogram.stub!(:new).and_return histogram
    @agent.histogram(:test_histogram).should == histogram
  end
  
  it "should add a meter instrument correctly" do
    @meter = Metrics::Instruments::Meter.new
    Metrics::Instruments::Meter.stub!(:new).and_return @meter

    @agent.meter(:test_meter).should == @meter
  end

  it "should add a timer instrument correctly" do
    @meter = Metrics::Instruments::Timer.new
    Metrics::Instruments::Timer.stub!(:new).and_return @timer

    @agent.timer(:test_timer).should == @timer
  end

  it "should serialize a timer instrument correctly" do
    @agent.timer(:test_timer)
    @hash = JSON.parse(@agent.to_json)
    @hash["test_timer"].should_not be_nil
    @hash["test_timer"]["count"].should_not be_nil
    @hash["test_timer"]["count"].should == 0
  end
  
end
