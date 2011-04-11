require 'spec_helper'

describe Metrics::Statistics::Sample do
  before(:each) do
    @sample = Metrics::Statistics::Sample.new
  end
  
  %w( clear values size ).each do |method|
    it "should raise a NotImplementedError for ##{method}" do
      lambda do
        @sample.send(method)
      end.should raise_exception(NotImplementedError)
    end
  end
  
  it "should raise a NotImplementedError for 'update'" do
    lambda do
      @sample.update(0)
    end.should raise_exception(NotImplementedError)
  end
  
end
