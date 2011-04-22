require 'spec_helper'

describe Metrics::Instruments::Heartbeat do
  before(:each) do
    @heartbeat = Metrics::Instruments::Heartbeat.new
  end
  
  it "should create a new entity with nil" do
    @heartbeat.last.should == nil
  end
  
  it "should update to the current time when beat is called" do
      @heartbeat.beat
      @heartbeat.last.should be_within(1).of(Time.now)
  end

  it "should alias beat to go" do
    @heartbeat.go
    @heartbeat.last.should be_within(1).of(Time.now)
  end 

  it "should alias beat to pulse" do
    @heartbeat.pulse
    @heartbeat.last.should be_within(1).of(Time.now)
  end

  it "should convert the last heartbeat time to integer" do
    @heartbeat.beat
    @heartbeat.to_i.should be_within(1).of(Time.now.to_i)
  end

  it "should convert the last heartbeat time to string" do
    @heartbeat.beat
    @heartbeat.to_s.should == Time.now.to_s
  end
end
