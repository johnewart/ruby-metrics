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
    @instruments.register('counter', 'test_counter').should == @counter
    @instruments.registered.should == {'test_counter' => @counter}
  end
  
  it "should allow for registering a Meter instrument" do
    Metrics::Instruments::Meter.stub!(:new).and_return @meter
    @instruments.register('meter', 'test_meter').should == @meter
    @instruments.registered.should == {"test_meter" => @meter}
  end
  
  it "should generate JSON correctly" do 
    Metrics::Instruments::Meter.stub!(:new).and_return @meter
    @instruments.register('meter', 'test_meter').should == @meter
    @instruments.registered.should == {"test_meter" => @meter}
    
    @instruments.to_json.should == "{\"test_meter\":\"{\\\"one_minute_rate\\\":0.0,\\\"five_minute_rate\\\":0.0,\\\"fifteen_minute_rate\\\":0.0}\"}"
  end
  
end