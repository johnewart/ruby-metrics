require 'spec_helper'

describe Metrics::Instruments do
  before(:each) do
    @instruments = Metrics::Instruments
    @instruments.unregister_all
    
    @counter = Metrics::Instruments::Counter.new
    @meter = Metrics::Instruments::Meter.new
  end
  
  it "should initially have no instruments in its hash" do
    @instruments.registered.should == {}
  end
  
  it "should allow for registering a Counter instrument" do
    Metrics::Instruments::Counter.stub!(:new).and_return @counter
    @instruments.register(:counter, :test_counter).should == @counter
    @instruments.registered.should == {:test_counter => @counter}
  end
  
  it "should allow for registering a Meter instrument" do
    Metrics::Instruments::Meter.stub!(:new).and_return @meter
    @instruments.register(:meter, :test_meter).should == @meter
    @instruments.registered.should == {:test_meter => @meter}
  end

  it "should allow for registering a Histogram instrument using uniform sampling" do
    histogram = Metrics::Instruments::UniformHistogram.new
    Metrics::Instruments::UniformHistogram.stub!(:new).and_return histogram
    @instruments.register(:uniform_histogram, :test_histogram).should == histogram
    @instruments.registered.should == {:test_histogram => histogram}
  end

  it "should allow for registering a Histogram instrument using exponentially decaying sampling" do
    histogram = Metrics::Instruments::ExponentialHistogram.new
    Metrics::Instruments::ExponentialHistogram.stub!(:new).and_return histogram
    @instruments.register(:exponential_histogram, :test_histogram).should == histogram
    @instruments.registered.should == {:test_histogram => histogram}
  end

  
  it "should generate JSON correctly" do 
    Metrics::Instruments::Meter.stub!(:new).and_return @meter
    @instruments.register(:meter, :test_meter).should == @meter
    @instruments.registered.should == {:test_meter => @meter}
    
    @instruments.to_json.should == "{\"test_meter\":\"{\\\"one_minute_rate\\\":0.0,\\\"five_minute_rate\\\":0.0,\\\"fifteen_minute_rate\\\":0.0}\"}"
  end
  
  it "should not allow for creating a gauge with no block" do 
    lambda do
      @instruments.register :gauge, :test_gauge
    end.should raise_error(ArgumentError)
  end
  
  it "should allow for creating a gauge with a block" do 
    proc = Proc.new { "result" }
    @instruments.register :gauge, :test_gauge, &proc
  end

  context '#register_instrument' do
    it 'registers a new instrument' do
      lambda { Metrics::Instruments.register_instrument(:test, String) }.should_not raise_error
    end

    it 'returns the list of registered instruments' do
      Metrics::Instruments.register_instrument(:str, String)
      Metrics::Instruments.register_instrument(:int, Fixnum)

      inst = Metrics::Instruments.registered_instruments
      inst[:str].should == String
      inst[:int].should == Fixnum
    end
  end
end
