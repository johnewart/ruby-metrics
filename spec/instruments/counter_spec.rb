require 'spec_helper'

describe Metrics::Instruments::Counter do
  before(:each) do
    @counter = Metrics::Instruments::Counter.new
  end
  
  it "should create a new entity with zero as its value" do
    @counter.to_i.should == 0
  end
  
  it "should increment its counter by the value specified" do
    value = 1
    lambda do
      @counter.inc(value)
    end.should change{ @counter.to_i }.by(value)
  end
  
  it "should increment its counter by one by default" do
    lambda do
      @counter.inc
    end.should change{ @counter.to_i }.by(1)
  end
  
  it "should decrement its counter by the value specified" do
    value = 1
    lambda do
      @counter.dec(value)
    end.should change{ @counter.to_i }.by(-value)
  end
  
  it "should decrement its counter by one by default" do
    lambda do
      @counter.dec
    end.should change{ @counter.to_i }.by(-1)
  end
  
  it "should alias #incr to #inc" do
    lambda do
      @counter.incr
    end.should change{ @counter.to_i }.by(1)
  end
  
  it "should alias #decr to #dec" do
    lambda do
      @counter.decr
    end.should change{ @counter.to_i }.by(-1)
  end
  
  it "should clear the counter correctly" do 
    @counter.clear
    @counter.to_i.should == 0
  end
  
  it "should correctly represent the value as a string" do 
    @counter.clear
    @counter.to_i.should == 0
    @counter.to_s.should == "0"
  end
  
  it "should return the new count when incrementing" do
    count = @counter.to_i
    @counter.inc(value = 1).should == count + value
  end
  
  it "should return the new count when decrementing" do
    lambda do
      @counter.dec(1)
    end.should change{ @counter.to_i }.by(-1)
  end
  
end
