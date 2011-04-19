require 'spec_helper'

describe Metrics::Instruments::Calibration do

  describe '#new' do

    its(:duration_unit) { should equal(:seconds) }
    its(:rate_unit)     { should equal(:seconds) }

  end

end
