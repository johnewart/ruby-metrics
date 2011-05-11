require 'spec_helper'

describe Metrics::Instruments::Meter do
  before(:each) do
    Thread.stub!(:new).and_return do |block|
      # Do nothing
    end
  end

  it "should initialize averages to 0" do 
    meter = Metrics::Instruments::Meter.new
    meter.one_minute_rate.should == 0.0
    meter.five_minute_rate.should == 0.0
    meter.fifteen_minute_rate.should == 0.0
  end
  
  it "should increment count" do
    meter = Metrics::Instruments::Meter.new
    meter.mark(500)
    meter.counted.should == 500
  end
  
  it "should accept options for the constructor" do
    meter = Metrics::Instruments::Meter.new
  end
  
  context "A timer with an initial mark of 3 at a 1 second rate unit on a 5 second interval" do
    
    before(:each) do 
      @meter = Metrics::Instruments::Meter.new
      @meter.mark(3)
      @meter.tick()
    end

    def tick_for(seconds)
      count = ((seconds) / 5).to_i
      (1..count).each do
        @meter.tick()
      end
    end
    
    context "For a 1 minute window" do
      it "should have a rate of 0.6 events/sec after the first tick" do
        @meter.one_minute_rate.should == 0.6
      end
    
      it "should have a rate of 0.22072766470286553 events/sec after 1 minute" do
        tick_for(60)
        @meter.one_minute_rate.should == 0.22072766470286553
      end
    end
    
    context "For a 5 minute window" do
      it "should have a rate of 0.6 events/sec after the first tick" do
        @meter.five_minute_rate.should == 0.6
      end
    
      it "should have a rate of 0.49123845184678905 events/sec after 1 minute" do
        tick_for(60)
        @meter.five_minute_rate.should == 0.49123845184678905
      end
    end
    
    context "For a 15 minute window" do
      it "should have a rate of 0.6 events/sec after the first tick" do
        @meter.fifteen_minute_rate.should == 0.6
      end
      
      it "should have a rate of 36.0 events per minute after the first tick" do
        @meter.fifteen_minute_rate(:minutes).should == 36.0
      end
      
      it "should have a rate of 2160.0 events per hour after the first tick" do 
        @meter.fifteen_minute_rate(:hours).should == 2160.0
      end

      it "should have a rate of 0.5613041910189706 events/sec after 1 minute" do
        tick_for(60)
        @meter.fifteen_minute_rate.should == 0.5613041910189706
      end      
    end
  
  end
    
  
end