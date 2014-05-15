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

  class Test
    def initialize
      @gauge = Metrics::Instruments::Gauge.new { @status.to_s }
      @status = :new
    end

    def change_status
      @status = :old
    end

    def get_gauge
      @gauge.get
    end
  end

  it "gauge block within another class should be able to reference other classes variables" do
    test_class = Test.new
    test_class.get_gauge.should == "new"
    test_class.change_status
    test_class.get_gauge.should == "old"
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
