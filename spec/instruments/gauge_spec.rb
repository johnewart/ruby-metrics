require 'spec_helper'

describe Metrics::Instruments::Gauge do
  before(:each) do
  end

  it "should create a new gauge" do
    callback = Proc.new {}
    @gauge = Metrics::Instruments::Gauge.new &callback
  end
  
  it "should correctly callback the block given when we call Gauge#get" do
    result = 42
    
    callback = Proc.new do 
      {
        :result => result
      }
    end
    
    @gauge = Metrics::Instruments::Gauge.new &callback
    
    @gauge.get[:result].should == 42
    
    result += 1
    
    @gauge.get[:result].should == 43
  end
  
  it "should JSONify the results when you call to_s" do
    result = 42
    
    callback = Proc.new do 
      {
        :result => result
      }
    end
    
    @gauge = Metrics::Instruments::Gauge.new &callback
    
    @gauge.to_s.should == "{\"result\":42}"
  end
  
end
