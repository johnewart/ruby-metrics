require "rack/test"

describe Metrics::Integration::Rack::Middleware do
  include Rack::Test::Methods
  
  def app(status = 200, body = ["Hello, World!"], headers = {})
    @app ||= lambda{ |env| [status, {'Content-Type' => 'text/plain', 'Content-Length' => body.to_s.size.to_s}.merge(headers), body] }
  end
  alias_method :original_app, :app
  
  describe "without integration" do
    it "should work normally" do
      get "/"
      
      last_response.should be_ok
      last_response.body.should == "Hello, World!"
    end
  end
  
  describe "with integration" do
    def app(options = {})
      @integrated_app ||= Metrics::Integration::Rack::Middleware.new(original_app, options)
    end
    def agent
      app.agent
    end
    
    it "should work normally" do
      get "/"
      
      last_response.should be_ok
      last_response.body.should == "Hello, World!"
    end
    
    it "should show stats for default endpoint" do
      get "/stats"
      last_response.should be_ok
      last_response.body.should == agent.to_json
    end
    
    it "should make 'metrics.agent' available to the upstream environment" do
      @app = lambda do |env|
        env['metrics.agent'].should be_a(Metrics::Agent)
        env['metrics.agent'].should == agent
        [200, {}, []]
      end
      
      get '/'
      last_response.should be_ok
    end
    
    describe "integration metrics" do
      
      it "should count all requests" do
        lambda do
          get '/'
        end.should change{ app.requests.count }.by(1)
      end
      
      it "should count uncaught exceptions" do
        @app = lambda{ |env| raise }
        lambda do
          lambda do
            get '/'
          end.should raise_error
        end.should change{ app.uncaught_exceptions.to_i }.by(1)
      end
      
      it "should time request length" do
        length = 0.1
        @app = lambda{ |env| sleep(length); [200, {}, ['']] }
        get '/'
        app.requests.mean.should be_within(length / 10).of(length)
      end
      
      [ 200, 304, 404, 500].each do |status|
        it "should count #{status} HTTP status code as #{status / 100}xx" do
          @app = lambda{ |env| [status, {}, []] }
          lambda do
            get '/'
          end.should change{ app.status_codes[status / 100].to_i }.by(1)
        end
      end

      it "should build timer JSON properly" do
        agent_h = JSON.parse(agent.to_json)
        agent_h["_requests"].should_not be_nil
        agent_h["_requests"]["count"].should == app.requests.count
      end

      it "should serve timer JSON properly" do
        get "/stats"
        agent_j = last_response.body
        h = JSON.parse(agent_j)
        h["_requests"].should_not be_nil
        h["_requests"]["count"].should == app.requests.count
      end

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
  
end
