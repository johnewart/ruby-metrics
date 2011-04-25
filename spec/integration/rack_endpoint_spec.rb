require "rack/test"

describe Metrics::Integration::Rack::Endpoint do
  include Rack::Test::Methods
  
  def app(options = {})
    @app ||= Metrics::Integration::Rack::Endpoint.new(options)
  end
  def agent
    app.agent
  end
  
  it "should show stats" do
    get "/"
    last_response.should be_ok
    last_response.body.should == agent.to_json
  end
  
  context "configuring" do
    
    context "agent" do
      it "should create an agent by default" do
        app(:agent => nil)
        agent.should be_a(Metrics::Agent)
      end
      
      it "should use an agent if provided" do
        @agent = Metrics::Agent.new
        app(:agent => @agent)
        agent.should be_a(Metrics::Agent)
        agent.should == @agent
      end
    end
    
    context "show" do
      it "should match a string to the PATH_INFO exactly" do
        app(:show => "/foo")
        get '/foo'
        last_response.should be_ok
        last_response.body.should == agent.to_json
      end
      
      it "should match a regular expression to the PATH_INFO" do
        app(:show => /bar/)
        get '/foobarbaz'
        last_response.should be_ok
        last_response.body.should == agent.to_json
      end
      
      it "should call `call` on the show option if it responds to it" do
        app(:show => lambda{ |env| env['PATH_INFO'] == "/bing" })
        get '/bing'
        last_response.should be_ok
        last_response.body.should == agent.to_json
      end
    end
    
  end
  
end
