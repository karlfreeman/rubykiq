$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "bundler"
Bundler.setup
begin; require "awesome_print"; rescue LoadError; end

require "rspec"

require "support/pry"
require "support/timecop"
require "support/simplecov"

require "rubykiq"

# used as a stupid mixin class
class DummyClass
end

#
RSpec.configure do |config|

  #
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  #
  def jruby?
    defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
  end

  #
  def wrap_in_synchrony?(driver)

    yield unless driver == :synchrony

    EM.synchrony do
      yield if block_given?
      EM.stop
    end

  end

end