## What is this?

This is a Ruby version of [metrics][metrics], developed by Coda Hale at Yammer. 

## What's in this?

Right now, we have:

* Counters
* Timers

Upcoming:

* Gauges
* Histograms


## Getting Started

The goal of ruby-metrics is to get up and running quickly. You start an agent, register some instruments, and they're exported over HTTP via JSON. For example, getting started with a counter would look like this:

    @metrics = Metrics::Agent.new()
    @metrics.start

    counter = @metrics.add_instrument('counter', 'my_counter')
    counter.inc(1)
    counter.inc(1)

Then, hitting localhost:8081/status would yield:

    {"my_counter":"2"}


[metrics]: https://github.com/codahale/metrics