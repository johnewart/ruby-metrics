require 'spec_helper'

describe Metrics::Instruments::Static do
  before(:each) do
    @static = Metrics::Instruments::Static.new
  end
  
  it 'stores and retrieves value' do
    @static[:foo] = :bar
    @static[:foo].should == :bar
  end
  
  it "should accurately represent itself using JSON" do
    @static[:foo] = :bar
    @static[:now] = '2010-20-11 11:23:40'
    
    @static.to_s.should == '{"foo":"bar","now":"2010-20-11 11:23:40"}'
  end
end
