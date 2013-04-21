# Rubykiq ( WIP ) [![Gem Version](https://badge.fury.io/rb/rubykiq.png)][gem] [![Build Status](https://travis-ci.org/karlfreeman/rubykiq.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/karlfreeman/rubykiq.png?travis)][gemnasium] [![Coverage Status](https://coveralls.io/repos/karlfreeman/rubykiq/badge.png?branch=master)][coveralls] [![Code Climate](https://codeclimate.com/github/karlfreeman/rubykiq.png)][codeclimate]

[Sidekiq] agnostic enqueuing using Redis.

[gem]: https://rubygems.org/gems/rubykiq
[travis]: http://travis-ci.org/karlfreeman/rubykiq
[gemnasium]: https://gemnasium.com/karlfreeman/rubykiq
[coveralls]: https://coveralls.io/r/karlfreeman/rubykiq
[codeclimate]: https://codeclimate.com/github/karlfreeman/rubykiq

[sidekiq]: http://mperham.github.com/sidekiq/

## Usage Examples
Sidekiq is a fantastic message processing library which has a simple and stable message format. Rubykiq aims to be a portable library to push jobs in to Sidekiq with as little overhead as possible.

```ruby
require 'rubykiq'

Rubykiq.push(:class => 'MyWorker', :args => ['foo', 1, :bat => 'bar']) # uses default queue unless specified
```

##### It's advised that using [Sidekiq::Client's push] method is going to be better in most everyday cases

[sidekiq::client's push]: https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/client.rb#L36

## Features

* [Redis][] has support for [alternative drivers](https://github.com/redis/redis-rb#alternate-drivers), Rubykiq is tested with these in mind. ( eg em-synchrony )
* Some minor safety / parsing around the `:at` parameter to support `Time`, `Date` and `String` timestamps
* Simplier setup with less ( gem ) dependencies

[redis]: https://github.com/redis/redis-rb

## Supported Ruby Versions
This library aims to support and is [tested against][travis] the following Ruby
implementations:

* Ruby 1.9.2 (drivers: ruby, hiredis, synchrony)
* Ruby 1.9.3 (drivers: ruby, hiredis, synchrony)
* Ruby 2.0.0 (drivers: ruby, hiredis, synchrony)
* [JRuby][] (drivers: ruby)
* [Rubinius][] (drivers: ruby)

[jruby]: http://www.jruby.org/
[rubinius]: http://rubini.us/

# Credits

Inspiration:

- [Michael Grosser's Enqueue into Sidkiq post](http://grosser.it/2013/01/17/enqueue-into-sidekiq-via-pure-redis-without-loading-sidekiq/)

Cribbed:

- [Sidekiq's internal client class](https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/client.rb)
- [Sidekiq's internal redis class](https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/redis_connection.rb)
- [Sidekiq's FAQ](https://github.com/mperham/sidekiq/wiki/FAQ)
