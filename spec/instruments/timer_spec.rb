require 'spec_helper'

describe Metrics::Instruments::Timer do
  before(:each) do
    Thread.stub!(:new).and_return do |block|
      # Do nothing
    end
  end
  
  context "An empty timer" do
    before(:each) do 
      @timer = Metrics::Instruments::Timer.new
    end
    
    it "should have a max of zero" do
      @timer.max.should == 0
    end

    it "should have a min of zero" do
      @timer.min.should == 0
    end

    it "should have a mean of zero" do
      @timer.mean.should == 0
    end

    it "should have a min of zero" do
      @timer.std_dev.should == 0
    end
    
    it "should have quantiles of zero" do
      @timer.quantiles.should == {0.99=>0.0, 0.97=>0.0, 0.95=>0.0, 0.75=>0.0, 0.5=>0.0, 0.25=>0.0}
    end
    
    it "should have a mean rate of zero" do
      @timer.mean_rate.should == 0
    end

    it "should have a one-minute rate of zero" do
      @timer.one_minute_rate.should == 0
    end

    it "should have a five-minute rate of zero" do
      @timer.five_minute_rate.should == 0
    end

    it "should have a fifteen-minute rate of zero" do
      @timer.fifteen_minute_rate.should == 0
    end

    it "should have no values stored" do
      @timer.values.length.should == 0
    end

  end
  
  context "Timing some events" do
    before(:each) do
      @timer = Metrics::Instruments::Timer.new({:duration_unit => :milliseconds, :rate_unit => :seconds})
      @timer.update(10, :milliseconds)
      @timer.update(20, :milliseconds)
      @timer.update(20, :milliseconds)
      @timer.update(30, :milliseconds)
      @timer.update(40, :milliseconds)
    end

    it "should have counted 5 events" do
      @timer.count.should == 5
    end
    
    it "should accurately calculate the minimum duration" do
      @timer.min.should == 10
    end

    it "should accurately calculate the maximum duration" do
      @timer.max.should == 40
    end

    it "should accurately calculate the mean duration" do
      @timer.mean.should == 24
    end

    it "should accurately calculate the standard deviation of the durations" do
      @timer.std_dev.should == 11.401754901476078
    end
    
    it "should accurately calculate percentiles" do 
      @timer.quantiles.should == {0.99=>39.6, 0.97=>38.8, 0.95=>38.0, 0.75=>30.0, 0.5=>20.0, 0.25=>20.0}
    end
    
    it "should contain the series added" do
      @timer.values.sort.should == [10, 20, 20, 30, 40]
    end
    
    it "should accurately represent itself using JSON" do
      @timer.to_s.should == "{\"count\":5,\"rates\":{\"one_minute_rate\":0.0,\"five_minute_rate\":0.0,\"fifteen_minute_rate\":0.0,\"unit\":\"seconds\"},\"durations\":{\"min\":10.0,\"max\":40.0,\"mean\":24.0,\"percentiles\":{\"0.25\":20.0,\"0.5\":20.0,\"0.75\":30.0,\"0.95\":38.0,\"0.97\":38.8,\"0.98\":39.2,\"0.99\":39.6},\"unit\":\"milliseconds\"}}"
    end
  end
  
  context "Timing blocks of code" do
    before(:each) do
      @timer = Metrics::Instruments::Timer.new({:duration_unit => :nanoseconds, :rate_unit => :nanoseconds})
    end
    
    it "should return the result of the block passed" do       
      result = @timer.time do 
        sleep(0.25)
        "narf"
      end

      result.should == "narf"
      
      @timer.max.should >= 250000000
      @timer.max.should <= 300000000

    end
  end
  
end
