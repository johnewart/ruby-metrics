require 'spec_helper'

describe Metrics::Instruments::Calibration do

  subject { Metrics::Instruments::Calibration.new(:units) }

  describe '#new' do

    context 'given a unit :units' do

      its(:duration_unit) { should equal(:units) }
      its(:rate_unit)     { should equal(:units) }

    end

  end

  describe '#calibrate' do

    context 'given another calibration' do

      let(:calibration) { Metrics::Instruments::Calibration.new(:units) }

      before(:all) do
        calibration.duration_unit = :fake_units
        calibration.rate_unit = :fake_units
      end

      it "sets its duration unit to the given calibration's duration unit" do
        expect {
          subject.calibrate(calibration)
        }.to change(subject, :duration_unit).to(:fake_units)
      end

      it "sets its rate unit to the given calibration's rate unit" do
        expect {
          subject.calibrate(calibration)
        }.to change(subject, :rate_unit).to(:fake_units)
      end

    end

  end

end
