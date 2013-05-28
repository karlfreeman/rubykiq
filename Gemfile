source "https://rubygems.org"

gem "rake", ">= 1.2"
gem "yard"

# platforms :ruby_18 do
# end
# platforms :ruby, :mswin, :mingw do
# end
# platforms :jruby do
# end

gem "connection_pool", :git => "git://github.com/karlfreeman/connection_pool.git", :branch => "1.8.7-support"

gem "hiredis", ">= 0.4.5", :require => false
gem "em-synchrony", :require => false

group :development do
  gem "kramdown", ">= 0.14"
  gem "pry"
  gem "pry-debugger", :platforms => :mri_19
  gem "awesome_print"
end

group :test do
  gem "rspec"
  gem "rspec-smart-formatter"
  gem "vcr"
  gem "timecop"
  gem "simplecov", :require => false
  gem "coveralls", :require => false
  gem "cane", :require => false, :platforms => :ruby_19
end

gemspec