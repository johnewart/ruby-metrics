require 'spec_helper'

describe Metrics::Statistics::ExponentialSample do
  before(:each) do
  end
  
  it "should have a size equal 0 intially no matter to the initialization parameter" do 
    sample = Metrics::Statistics::ExponentialSample.new(100)
    sample.size.should == 0
    
  end
  
  it "should have an empty backing hash initially" do
    sample = Metrics::Statistics::ExponentialSample.new(100)
    sample.values.length.should == 0
  end
  
  
  context "A sample of 100 out of 1000 elements" do
    before(:each) do
      @population = (0..99).to_a
      @sample =  Metrics::Statistics::ExponentialSample.new(1000, 0.99)
      @population.each do |datum|
        @sample.update(datum)
      end
    end
    
    it "should have 100 elements" do
      @sample.size.should == 100
      @sample.values.length.should == 100
    end

    it "should only have elements from the population" do
      values = @sample.values
      @population.each do |datum|
        values.should include datum
      end
    end
  end

  context "A heavily-biased sample of 100 out of 1000 elements" do
    before(:each) do
      @population = (0..99).to_a
      @sample =  Metrics::Statistics::ExponentialSample.new(1000, 0.01)
      @population.each do |datum| 
        @sample.update(datum)
      end
    end

    it "should have 100 elements" do
      @sample.size.should == 100
      @sample.values.length.should == 100
    end

    it "should only have elements from the population" do
      values = @sample.values
      @population.each do |datum|
        values.should include datum
      end
    end
    
    it "should add another element when updating" do 
      @sample.update(42)
      @sample.size.should == 101
      @sample.values.should include 42
    end
    
    it "should rescale when the clock is one hour in the future or more" do 
      future_time = Time.now + (60 * 60)
      Time.stub(:now).and_return future_time
      @sample.update(42)
      @sample.size.should == 101
      
      values = @sample.values
      
      @population.each do |datum|
        values.should include datum
      end
      
      values.should include 42
    end
  end
  
  context "A heavily-biased sample of 1000 out of 1000 elements" do
    before(:each) do
      @population = (0..999).to_a
      @sample =  Metrics::Statistics::ExponentialSample.new(1000, 0.01)
      @population.each do |datum| 
        @sample.update(datum)
      end
    end
    
    it "should have 1000 elements" do
      @sample.size.should == 1000
      @sample.values.length.should == 1000
    end

    it "should only have elements from the population" do
      values = @sample.values
      @population.each do |datum|
        values.should include datum
      end
    end
    
    it "should replace an element when updating" do 
      @sample.update(4242)
      @sample.size.should == 1000
      @sample.values.should include 4242
    end
    
    it "should rescale so that newer events are higher in priority in the hash" do 
      future_time = Time.now + (60 * 60)
      Time.stub(:now).and_return future_time
      
      @sample.update(2121)
      

      @sample.size.should == 1000

      future_time = Time.now + (60 * 60 * 2)
      Time.stub(:now).and_return future_time
      
      @sample.update(4242)      
      @sample.size.should == 1000
      
      values = @sample.values
      
      values.length.should == 1000
      values.should include 4242
      values.should include 2121
      
      # Most recently added values in time should be at the end with the highest priority
      values[999].should == 4242
      values[998].should == 2121
    end
  end
  
end
