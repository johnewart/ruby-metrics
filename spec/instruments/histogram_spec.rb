require 'spec_helper'

# This is compared to results from R using the built-in old-faithful dataset

describe Metrics::Instruments::Histogram do

  context "using a uniform sample" do
    before(:each) do
      @histogram = Metrics::Instruments::Histogram.new
      data = %w(3.600 1.800 3.333 2.283 4.533 2.883 4.700 3.600 1.950 4.350 1.833 3.917 4.200 1.750 4.700 2.167 1.750 4.800 1.600 4.250 1.800 1.750 3.450 3.067 4.533 3.600 1.967 4.083 3.850 4.433 4.300 4.467 3.367 4.033 3.833 2.017 1.867 4.833 1.833 4.783 4.350 1.883 4.567 1.750 4.533 3.317 3.833 2.100 4.633 2.000 4.800 4.716 1.833 4.833 1.733 4.883 3.717 1.667 4.567 4.317 2.233 4.500 1.750 4.800 1.817 4.400 4.167 4.700 2.067 4.700 4.033 1.967 4.500 4.000 1.983 5.067 2.017 4.567 3.883 3.600 4.133 4.333 4.100 2.633 4.067 4.933 3.950 4.517 2.167 4.000 2.200 4.333 1.867 4.817 1.833 4.300 4.667 3.750 1.867 4.900 2.483 4.367 2.100 4.500 4.050 1.867 4.700 1.783 4.850 3.683 4.733 2.300 4.900 4.417 1.700 4.633 2.317 4.600 1.817 4.417 2.617 4.067 4.250 1.967 4.600 3.767 1.917 4.500 2.267 4.650 1.867 4.167 2.800 4.333 1.833 4.383 1.883 4.933 2.033 3.733 4.233 2.233 4.533 4.817 4.333 1.983 4.633 2.017 5.100 1.800 5.033 4.000 2.400 4.600 3.567 4.000 4.500 4.083 1.800 3.967 2.200 4.150 2.000 3.833 3.500 4.583 2.367 5.000 1.933 4.617 1.917 2.083 4.583 3.333 4.167 4.333 4.500 2.417 4.000 4.167 1.883 4.583 4.250 3.767 2.033 4.433 4.083 1.833 4.417 2.183 4.800 1.833 4.800 4.100 3.966 4.233 3.500 4.366 2.250 4.667 2.100 4.350 4.133 1.867 4.600 1.783 4.367 3.850 1.933 4.500 2.383 4.700 1.867 3.833 3.417 4.233 2.400 4.800 2.000 4.150 1.867 4.267 1.750 4.483 4.000 4.117 4.083 4.267 3.917 4.550 4.083 2.417 4.183 2.217 4.450 1.883 1.850 4.283 3.950 2.333 4.150 2.350 4.933 2.900 4.583 3.833 2.083 4.367 2.133 4.350 2.200 4.450 3.567 4.500 4.150 3.817 3.917 4.450 2.000 4.283 4.767 4.533 1.850 4.250 1.983 2.250 4.750 4.117 2.150 4.417 1.817 4.467)
      data.each do |point|
        @histogram.update(point.to_f)
      end
      @histogram.count.should == 272
    end
  
    it "should update variance correctly" do
      @histogram.variance.should == 1.3027283328494685
    end
  
    it "should calculate standard deviations properly" do
      @histogram.std_dev.should == 1.1413712511052083
    end
  
    it "should accurately calculate quantiles" do
      quantiles = @histogram.quantiles([0.99, 0.98, 0.95, 0.80, 0.57, 0.32])
      quantiles.should == 
        {
          0.99 => 5.009570000000001, 
          0.98 => 4.93300,
          0.95 => 4.81700, 
          0.80 => 4.53300, 
          0.57 => 4.13300, 
          0.32 => 2.39524
        }
    end

    it "should accurately calculate the mean" do 
      @histogram.mean.should == 3.4877830882352936
    end
  
    it "should accurately represent itself using JSON" do
      @histogram.to_s.should == "{\"min\":1.6,\"max\":5.1,\"mean\":3.4877830882352936,\"variance\":1.3027283328494685,\"percentiles\":{\"0.25\":2.16275,\"0.5\":4.0,\"0.75\":4.45425,\"0.95\":4.817,\"0.97\":4.8977900000000005,\"0.98\":4.933,\"0.99\":5.009570000000001}}"
    end
  
    it "should return correct values for mean, std. deviation and variance when no elements are in the histogram" do
      histogram = Metrics::Instruments::Histogram.new
      histogram.variance.should == 0.0
      histogram.mean.should == 0.0
      histogram.std_dev.should == 0.0
    end
  
    it "should return the first value as the quantile if only one value" do
      histogram = Metrics::Instruments::Histogram.new
      histogram.update(42)
      histogram.quantiles([0.50]).should == {0.50 => 42}
    end  

    it "should return the last value as the 100%" do
      histogram = Metrics::Instruments::Histogram.new
      histogram.update(42)
      histogram.update(64)
      histogram.quantiles([1.00]).should == {1.00 => 64}
    end  


    it "should return correct values for min and max" do
      histogram = Metrics::Instruments::Histogram.new
      histogram.update(42)
      histogram.min.should == 42
      histogram.max.should == 42
    end

    context "resetting the histogram" do

      it "should clear data correctly" do
        sample = Metrics::Statistics::UniformSample.new    
        sample.should_receive(:clear)
        Metrics::Statistics::UniformSample.should_receive(:new).and_return sample

        histogram = Metrics::Instruments::Histogram.new
        histogram.clear
        histogram.max.should == 0.0
        histogram.min.should == 0.0
      end
      
    end
  end
  
  context "using an exponentially weighted sample" do
    it "should return correct values for mean, std. deviation and variance when no elements are in the histogram" do
      histogram = Metrics::Instruments::Histogram.new(:exponential)
      histogram.variance.should == 0.0
      histogram.mean.should == 0.0
      histogram.std_dev.should == 0.0
    end
  end
  
end
