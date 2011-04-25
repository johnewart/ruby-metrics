
## What is this?

This is a Ruby version of performance metrics inspired by [metrics][metrics] developed by Coda Hale at Yammer. Currently this is under *heavy* development -- it needs Gem packaging, more features, validation of metrics, more functional testing, and a little better test coverage. Pull requests happily accepted, please include docs and tests where possible!

## What needs to be done?

Among other important things, this needs to be made more thread-safe. I'm currently looking at Mr. Nutter's ruby-atomic gem for making this less tedious but any suggestions are welcome!

## What's in this?

Right now, I have:

* Counters
* Meters
* Gauges
* Histograms w/ uniform sampling
* Histograms w/ exponentially decaying sampling
* Timers

## Getting Started

The goal of ruby-metrics is to get up and running quickly. You start an agent, register some instruments, and they're exported over HTTP via JSON. For example, getting started with a counter would look like this:

    @metrics = Metrics::Agent.new

    counter = @metrics.counter :my_counter
    counter.incr
    counter.incr

    puts @metrics.to_json
    #=> {"my_counter":"2"}


## Integration

Integrating ruby-metrics into existing applications is entirely up to your needs. Provided options include:

* Embedded WEBrick listener:

  This runs a background thread and enables HTTP access to a local port (8001 by default) for a JSON representation of the current metrics.

``` ruby
require 'ruby-metrics/integration/webrick'
@agent = Metrics::Agent.new
@agent.start(:port => 8081)
```

* Rack Middleware:

  This will add metrics such as `requests` (a timer) as well as counters for each class of HTTP status code (1xx, 2xx, etc). Also counts uncaught exceptions before reraising.
  Provides a configurable path option (`:show`) to trigger the return of the metrics (as JSON) when the request path matches exactly (a string), as a regular expression, or as any object that responds to `call` for custom logic (passed the whole `env`).

``` ruby
require 'ruby-metrics'
@agent = Metrics::Agent.new

use Metrics::Integration::Rack::Middleware, :agent => @agent, :show => '/stats'

run app
```

* Rack Endpoint:

  Use this to expose an endpoint for external consumption for your metrics.
  Works best when used with a URLMap or mounted in addition to other routes, like Rails' `mount` route matcher.

``` ruby
require 'ruby-metrics'
@agent = Metrics::Agent.new

run Metrics::Integration::Rack::Endpoint.new(:agent => @agent)
```

or

``` ruby
# in config/router.rb
mount Metrics::Integration::Rack::Endpoint.new(:agent => @agent)
```

[metrics]: https://github.com/codahale/metrics

## License

Copyright 2011 John Ewart <john@johnewart.net>. Released under the MIT license. See the file LICENSE for further details.
