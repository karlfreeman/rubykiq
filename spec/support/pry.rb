if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby'
  require 'pry' unless ENV['CI']
end
