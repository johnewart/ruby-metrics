require 'spec_helper'

describe Metrics::Instruments do

  subject { Metrics::Instruments }

  before(:each) do
    subject.unregister_all
  end

  context 'initially' do

    it 'should have no registered instruments' do
      subject.registered.should be_empty
    end

  end

  describe '.register' do

    Metrics::Instruments.types.each do |instrument, instrument_class|

      context "given :#{instrument}, a name, and a block" do

        let(:name) { :test }
        let(:block) { Proc.new { :block } }

        it "should return a new #{instrument_class}" do
          subject.register(instrument, name, &block).
            should be_a(instrument_class)
        end

        it "should register a new #{instrument_class} under the given name" do
          test_instrument = double(instrument_class)
          instrument_class.stub!(:new).and_return(test_instrument)

          subject.register(instrument, name, &block)
          subject.registered[name].should eql(test_instrument)
        end
        
      end

    end

  end

  describe '.unregister_all' do

    before do
      instrument = Metrics::Instruments.types.keys.first
      subject.register(instrument, instrument) do
        :block
      end
    end

    it 'should clear the registered instruments' do
      expect {
        subject.unregister_all
      }.to change(subject, :registered).to({})
    end

  end

  describe '.registered' do

    let(:fake_counter) { double(Metrics::Instruments::Counter) }

    before do
      Metrics::Instruments::Counter.stub!(:new).and_return(fake_counter)
      subject.register(:counter, :test_counter)
    end

    it 'should return a Hash of registered names and instruments' do
      subject.registered.should eql({
        :test_counter => fake_counter
      })
    end

  end

  describe '.to_json' do

    let(:registered) { double(:@registered) }

    before do
      subject.stub!(:registered).and_return(registered)
    end

    it 'should return .registered JSONified' do
      registered.should_receive(:to_json)
      subject.to_json
    end

  end

end
