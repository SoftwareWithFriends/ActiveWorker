source "https://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem "rdoc", "~> 3.12"
  gem "bundler"
  gem "jeweler", "~> 1.8.3"
end

group :test do
  gem 'mocha', require: false
  gem 'activesupport'
  gem 'test-unit'
end

gem 'mongoid'
gem 'bson_ext' #, '=1.4.0'
gem 'resque', :git => "git://github.com/SoftwareWithFriends/resque.git", :branch  => "FEATURE_logging_changes"
