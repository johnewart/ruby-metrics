require 'spec_helper'

describe Metrics::Instruments::Meter do
  before(:each) do
  end

  it "should initialize averages to 0" do 
    meter = Metrics::Instruments::Meter.new()
    meter.one_minute_rate.should == 0.0
    meter.five_minute_rate.should == 0.0
    meter.fifteen_minute_rate.should == 0.0
  end
  
  it "should increment count" do
    meter = Metrics::Instruments::Meter.new()
    meter.mark(500)
    meter.counted.should == 500
    meter.uncounted.should == 500
  end
  
  it "should accept options for the constructor" do
    meter = Metrics::Instruments::Meter.new({:interval => "10 seconds", :rateunit => "5 seconds"})
  end
  
  it "should tick properly" do
    meter = Metrics::Instruments::Meter.new({:interval => "5 seconds", :rateunit => "1 second", :nothread => true})
    meter.mark(100)
    meter.tick()
    meter.five_minute_rate.should == 19.999999999999996
  end
  
  it "should tick twice accurately" do
    meter = Metrics::Instruments::Meter.new({:interval => "5 seconds", :rateunit => "1 second", :nothread => true})
    meter.mark(100)
    meter.tick()
    meter.five_minute_rate.should == 19.999999999999996
    meter.tick()
    meter.five_minute_rate.should == 16.319822341482705
  end
end