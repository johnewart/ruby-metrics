require 'spec_helper'

describe Metrics::TimeUnit do
  it "should raise NotImplementedError for #to_nsec" do
    begin
      Metrics::TimeUnit.to_nsec
    rescue NotImplementedError
      true
    else
      fail
    end
  end
end
