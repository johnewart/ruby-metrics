require 'spec_helper'

describe Metrics::Instruments do
  before(:each) do
    @instruments = Metrics::Instruments
    @instruments.unregister_all
    
    @counter = Metrics::Instruments::Counter.new
    @timer = Metrics::Instruments::Timer.new
  end

  it "should initially have no instruments in its hash" do
    @instruments.registered.should == {}
  end
  
  it "should allow for registering a Counter instrument" do
    Metrics::Instruments::Counter.stub!(:new).and_return @counter
    @instruments.register('counter', 'test_counter').should == @counter
    @instruments.registered.should == {'test_counter' => @counter}
  end
  
  it "should allow for registering a Timer instrument" do
    Metrics::Instruments::Timer.stub!(:new).and_return @timer
    @instruments.register('timer', 'test_timer').should == @timer
    @instruments.registered.should == {"test_timer" => @timer}
  end
  
  it "should generate JSON correctly" do 
    Metrics::Instruments::Timer.stub!(:new).and_return @timer
    @instruments.register('timer', 'test_timer').should == @timer
    @instruments.registered.should == {"test_timer" => @timer}
    
    @instruments.to_json.should == "{\"test_timer\":\"{\\\"one_minute_rate\\\":0.0,\\\"five_minute_rate\\\":0.0,\\\"fifteen_minute_rate\\\":0.0}\"}"
  end
  
end