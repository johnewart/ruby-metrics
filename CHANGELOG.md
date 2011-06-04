v0.8.6 -- June 2, 2011
======================

* Updated tests for JSON serialization of instruments
* Fixed JSON serialization of some instruments

v0.8.5 -- May 11, 2011
======================

* Removed dependency on quantity gem -- conflicted with ActiveSupport
* Updated code to compute some unit conversions manually instead of depending on quantity


v0.8.0 -- April 26, 2011
========================

* Added timer example
* Changes to timer initialization
* Added register_with_options to support timers with different units or options
* Integrated Matt's changes for integration to modularize webrick and rack export options

v0.7.0 -- April 18, 2011
========================

* Replaced ruby-units with quantity
* Added time unit conversion internally
* Initial implementation of Timer instrument
* More spec tests to increase coverage


v0.6.0 -- April 15, 2011
========================

* Exponentially decaying samples for histograms
* Updates to Meter to use exponentially decaying samples
* Ability to override WEBrick port in constructor
* Updates to README

v0.5.0 -- April 13, 2011
========================

* Initial gem packaging (courtesy of @richardiux)
* Histograms
* Sampling classes for histograms
* Updates to weighted average calculations
* Tests, tests, tests!
* Mumblety-peg.... 

