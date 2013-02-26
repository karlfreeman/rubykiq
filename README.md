# Rubykiq ( WIP )
[![Gem Version](https://badge.fury.io/rb/rubykiq.png)][gem]
[![Build Status](https://travis-ci.org/karlfreeman/rubykiq.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/karlfreeman/rubykiq.png?travis)][gemnasium]
[![Code Climate](https://codeclimate.com/github/karlfreeman/rubykiq.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/karlfreeman/rubykiq/badge.png?branch=master)][coveralls]

[gem]: https://rubygems.org/gems/rubykiq
[travis]: http://travis-ci.org/karlfreeman/rubykiq
[gemnasium]: https://gemnasium.com/karlfreeman/rubykiq
[codeclimate]: https://codeclimate.com/github/karlfreeman/rubykiq
[coveralls]: https://coveralls.io/r/karlfreeman/rubykiq

[Sidekiq] agnostic enqueuing using Redis.

[sidekiq]: http://mperham.github.com/sidekiq/

## Usage Examples
Sidekiq is a fantastic message processing library which has a simple and stable message format. Rubykiq aims to be a portable library to push jobs in to Sidekiq with as little overhead as possible.

```ruby
require 'rubykiq'

# preview syntax
Rubykiq.queue('my_queue').push(:class => 'MyWorker', :args => ['foo', 1, :bat => 'bar'])
Rubykiq.push(:class => 'MyWorker', :args => ['foo', 1, :bat => 'bar']) # uses default queue
```

##### It's advised that using [Sidekiq::Client's push] method is going to be better in most everyday cases

[sidekiq::client's push]: https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/client.rb#L36

## Supported Ruby Versions
This library aims to support and is [tested against][travis] the following Ruby
implementations:

* Ruby 1.8.7
* Ruby 1.9.2
* Ruby 1.9.3
* Ruby 2.0.0
* [JRuby][]
* [Rubinius][]

[jruby]: http://www.jruby.org/
[rubinius]: http://rubini.us/


# Credits

Inspiration:

- [Michael Grosser's Enqueue into Sidkiq post](http://grosser.it/2013/01/17/enqueue-into-sidekiq-via-pure-redis-without-loading-sidekiq/)

Cribbed:

- [Sidekiq's internal client class](https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/client.rb)
- [Sidekiq's internal redis class](https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/redis_connection.rb)
- [Sidekiq's FAQ](https://github.com/mperham/sidekiq/wiki/FAQ)
