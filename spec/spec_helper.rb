$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "bundler"
Bundler.setup
begin; require "awesome_print"; rescue LoadError; end

require "rspec"

require "support/pry"
require "support/fakeredis"
require "support/timecop"
require "support/simplecov"

require "rubykiq"

# used as a stupid mixin class
class DummyClass
end

#
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end