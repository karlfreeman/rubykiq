source 'https://rubygems.org'

gem 'rake', '>= 1.2'
gem 'yard'

# platforms :ruby_18 do
# end
# platforms :ruby, :mswin, :mingw do
# end
# platforms :jruby do
# end

group :development do
  gem 'kramdown', '>= 0.14'
  gem 'pry'
  gem 'pry-debugger', :platforms => :mri_19
end

group :test do
  gem 'rspec'
  gem 'vcr'
  gem 'timecop'
  gem 'simplecov', :require => false
  gem 'coveralls', :require => false
end

gemspec