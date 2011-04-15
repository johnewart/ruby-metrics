
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
 
Upcoming:

* Timers 

## Getting Started

The goal of ruby-metrics is to get up and running quickly. You start an agent, register some instruments, and they're exported over HTTP via JSON. For example, getting started with a counter would look like this:

    @metrics = Metrics::Agent.new
    @metrics.start

    counter = @metrics.counter :my_counter
    counter.incr
    counter.incr

Then, hitting localhost:8001/status would yield:

    {"my_counter":"2"}


[metrics]: https://github.com/codahale/metrics

## License

Copyright 2011 John Ewart <john@johnewart.net>. Released under the MIT license. See the file LICENSE for further details.
