require 'spec_helper'

describe Metrics::Instruments::Meter do
  before(:each) do
  end

  it "should initialize averages to 0" do 
    @timer = Metrics::Instruments::Meter.new()
    @timer.one_minute_rate.should == 0.0
    @timer.five_minute_rate.should == 0.0
    @timer.fifteen_minute_rate.should == 0.0
  end
  
  it "should increment count" do
    @timer = Metrics::Instruments::Meter.new()
    @timer.mark(500)
    @timer.counted.should == 500
    @timer.uncounted.should == 500
  end
  
  it "should accept options for the constructor" do
    @timer = Metrics::Instruments::Meter.new({:interval => "10 seconds", :rateunit => "5 seconds"})
  end
  
  it "should tick properly" do
    @timer = Metrics::Instruments::Meter.new({:interval => "5 seconds", :rateunit => "1 second", :nothread => true})
    @timer.mark(100)
    @timer.tick()
    @timer.five_minute_rate.should == 19.999999999999996
  end
end