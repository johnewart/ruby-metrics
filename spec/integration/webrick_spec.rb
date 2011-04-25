require "rack/test"

describe Metrics::Integration::WEBrick do
  
  it "should start the WEBrick thread" do
    Thread.stub!(:new).and_return do |block|
      block.call
    end
    
    mock_server = mock(WEBrick::HTTPServer)
    WEBrick::HTTPServer.should_receive(:new).and_return mock_server
    mock_server.should_receive(:mount)
    mock_server.should_receive(:start)
    
    Metrics::Integration::WEBrick.start
  end
  
end
