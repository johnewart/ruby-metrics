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
  
  context "to_json" do
    it "should serialize the current value" do
      result = 0
      gauge = Metrics::Instruments::Gauge.new{ result }
      
      gauge.to_json.should == result.to_s
      
      result = 2
      gauge.to_json.should == result.to_s
    end
  end
  
end
