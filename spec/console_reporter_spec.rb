require 'spec_helper.rb'

describe Metrics::ConsoleReporter do
  before :each do 
    out = File.new('/dev/null', 'w')
    @reporter = Metrics::ConsoleReporter.new(out)
  end
  
  it "should call the get method for gauge" do
    gauge = Metrics::Instruments::Gauge.new do
      "test"
    end
    Metrics::Instruments::Gauge.stub!(:new).and_return gauge
    gauge.should_receive(:get)
    @reporter.gauge :test_gauge do 
      "test"
    end
    @reporter.instance_eval { print_instruments }
  end
  
  it "should call the to_s method for counter" do
    counter = Metrics::Instruments::Counter.new
    Metrics::Instruments::Counter.stub!(:new).and_return counter
    counter.should_receive(:to_s)
    @reporter.counter(:test_counter)
    @reporter.instance_eval { print_instruments }
  end
  
  it "should call the count, mean_rate, one_minute_rate, five_minute_rate, fifteen_minute_rate methods for meter" do
    Thread.stub!(:new).and_return nil
    meter = Metrics::Instruments::Meter.new
    Metrics::Instruments::Meter.stub!(:new).and_return meter
    meter.should_receive(:count)
    meter.should_receive(:mean_rate)
    meter.should_receive(:one_minute_rate)
    meter.should_receive(:five_minute_rate)
    meter.should_receive(:fifteen_minute_rate)
    @reporter.meter(:test_meter)
    @reporter.instance_eval { print_instruments }
  end
  
  it "should call the min, max, mean, std_dev, quantiles methods for histogram" do
    uniform_histogram = Metrics::Instruments::UniformHistogram.new
    Metrics::Instruments::UniformHistogram.stub!(:new).and_return uniform_histogram
    uniform_histogram.stub!(:quantiles).and_return []
    uniform_histogram.should_receive(:quantiles)
    uniform_histogram.should_receive(:min)
    uniform_histogram.should_receive(:max)
    uniform_histogram.should_receive(:mean)
    uniform_histogram.should_receive(:std_dev)
    @reporter.uniform_histogram(:test_histogram)
    @reporter.instance_eval { print_instruments }
  end
end