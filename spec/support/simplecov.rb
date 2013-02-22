if !ENV['CI'] && defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby'
  require 'simplecov'
  SimpleCov.start do
    add_filter 'vendor'
  end
end