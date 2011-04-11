## What is this?

This is a Ruby version of performance metrics inspired by [metrics][metrics] developed by Coda Hale at Yammer. Currently this is under *heavy* development -- it needs Gem packaging, more features, validation of metrics, more functional testing, and a little better test coverage. Pull requests happily accepted, please include docs and tests where possible!

## What's in this?

Right now, I have:

* Counters
* Meters
* Gauges

Upcoming:

* Histograms
* Timers 

## Getting Started

The goal of ruby-metrics is to get up and running quickly. You start an agent, register some instruments, and they're exported over HTTP via JSON. For example, getting started with a counter would look like this:

    @metrics = Metrics::Agent.new
    @metrics.start

    counter = @metrics.counter :my_counter
    counter.incr
    counter.incr

Then, hitting localhost:8081/status would yield:

    {"my_counter":"2"}


[metrics]: https://github.com/codahale/metrics
