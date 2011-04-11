require 'spec_helper'

describe Metrics::Statistics::UniformSample do
  before(:each) do
  end
  
  it "should have a size equal to the initialization parameter" do 
    sample = Metrics::Statistics::UniformSample.new(100)
    sample.size.should == 100
    
  end
  
  it "should allocate an array of the requested size" do
    sample = Metrics::Statistics::UniformSample.new(100)
    sample.values.length.should == 100
    
    sample.values.each do |value|
      value.should == 0
    end
  end
  
  it "should update at the end of the list" do
    sample = Metrics::Statistics::UniformSample.new(100)
    (1..100).each do |i|
      sample.update(i)
    end
    
    values = sample.values
    
    (0..99).each do |index|
      values[index].should == (index + 1)
    end
  end
  
  it "should update a random entry in the list when it's full" do
    
    sample = Metrics::Statistics::UniformSample.new(100)
    sample.should_receive(:rand).with(any_args()).and_return(50)

    (1..101).each do |i|
      sample.update(i)
    end
    
    values = sample.values
    
    (0..49).each do |index|
      values[index].should == (index + 1)
    end
    
    values[50].should == 101
    
    (51..99).each do |index|
      values[index].should == (index + 1)
    end
    
  end
  
  
end
