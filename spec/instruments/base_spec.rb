require 'spec_helper'

describe Metrics::Instruments::Base do
  before(:each) do
    @base = Metrics::Instruments::Base.new
  end
  
  %w( to_i to_f to_json to_s ).each do |method|
    it "should raise a NotImplementedError for ##{method}" do
      lambda do
        @base.send(method)
      end.should raise_exception(NotImplementedError)
    end
  end
  
end
