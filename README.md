# Rubykiq [![Gem Version](https://badge.fury.io/rb/rubykiq.png)][gem] [![Build Status](https://travis-ci.org/karlfreeman/rubykiq.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/karlfreeman/rubykiq.png?travis)][gemnasium] [![Coverage Status](https://coveralls.io/repos/karlfreeman/rubykiq/badge.png?branch=master)][coveralls] [![Code Climate](https://codeclimate.com/github/karlfreeman/rubykiq.png)][codeclimate]

[gem]: https://rubygems.org/gems/rubykiq
[travis]: http://travis-ci.org/karlfreeman/rubykiq
[gemnasium]: https://gemnasium.com/karlfreeman/rubykiq
[coveralls]: https://coveralls.io/r/karlfreeman/rubykiq
[codeclimate]: https://codeclimate.com/github/karlfreeman/rubykiq

[Sidekiq] agnostic enqueuing using Redis.

[sidekiq]: http://mperham.github.com/sidekiq

Sidekiq is a fantastic message processing library which has a simple and stable message format. `Rubykiq` aims to be a portable library to push jobs in to Sidekiq with as little overhead as possible whilst having feature parity on `Sidekiq::Client`'s conventions.

## Features / Usage Examples

* [Redis][] has support for [alternative drivers](https://github.com/redis/redis-rb#alternate-drivers), Rubykiq is tested with these in mind. ( eg `:synchrony` )
* The `:at` parameter supports `Time`, `Date` and any `Time.parse`-able strings.
* Pushing multiple and singular jobs has the same interface ( simply nest args )
* Slightly less gem dependecies, and by that I mean `Sidekiq::Client` without `Celluloid` ( which is already very light! )

[redis]: https://github.com/redis/redis-rb

```ruby
require "rubykiq"

# will also detect REDIS_URL, REDIS_PROVIDER and REDISTOGO_URL ENV variables
Rubykiq.url = "redis://127.0.0.1:6379"

# alternative driver support ( :ruby, :hiredis, :synchrony )
Rubykiq.driver = :synchrony

# defaults to nil
Rubykiq.namespace = "background"

# uses "default" queue unless specified
Rubykiq.push(:class => "Worker", :args => ["foo", 1, :bat => "bar"])

# args are optionally set to empty
Rubykiq.push(:class => "Scheduler", :queue => "scheduler")

# will batch up multiple jobs
Rubykiq.push(:class => "Worker", :args => [["foo"], ["bar"]]) 

# at param can be a "Time", "Date" or any "Time.parse"-able strings
Rubykiq.push(:class => "DelayedHourMailer", :at => Time.now + 3600)
Rubykiq.push(:class => "DelayedDayMailer", :at => DateTime.now.next_day)
Rubykiq.push(:class => "DelayedMailer", :at => "2013-01-01T09:00:00Z")

# alias based sugar
job = { :class => "Worker" }
Rubykiq << job
```

## Caveats

* It's advised that using [Sidekiq::Client's push](https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/client.rb#L36) method when already a dependency is better in most everyday cases
* If you rely on any [Sidekiq Middleware](https://github.com/mperham/sidekiq/wiki/Middleware), Rubykiq is not aware of them so defaults will not be applied to the job hash.

## Supported Redis Drivers

* [Ruby](https://github.com/redis/redis-rb#alternate-drivers)
* [Hiredis](https://github.com/redis/hiredis)
* [Synchrony](https://github.com/igrigorik/em-synchrony)

## Supported Ruby Versions
This library aims to support and is [tested against][travis] the following Ruby
implementations:

* Ruby 1.9.2 (drivers: ruby, hiredis, synchrony)
* Ruby 1.9.3 (drivers: ruby, hiredis, synchrony)
* Ruby 2.0.0 (drivers: ruby, hiredis, synchrony)
* [JRuby][] (drivers: ruby)
* [Rubinius][] (drivers: ruby)

[jruby]: http://www.jruby.org
[rubinius]: http://rubini.us

# Credits

Inspiration:

- [Michael Grosser's Enqueue into Sidkiq post](http://grosser.it/2013/01/17/enqueue-into-sidekiq-via-pure-redis-without-loading-sidekiq/)

Cribbed:

- [Sidekiq's internal client class](https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/client.rb)
- [Sidekiq's internal redis class](https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/redis_connection.rb)
- [Sidekiq's FAQ](https://github.com/mperham/sidekiq/wiki/FAQ)
