$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "bundler"
Bundler.setup
begin; require "awesome_print"; rescue LoadError; end

require "rspec"

require "support/pry"
require "support/timecop"
require "support/simplecov"

require "rubykiq"

#
RSpec.configure do |config|
end