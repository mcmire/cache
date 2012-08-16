source :rubygems

# Production dependencies
gemspec

# Development dependencies

gem 'yard', '~> 0.8'
gem 'test-unit', '~> 2.5'

gem 'activesupport', '>= 2.3.11'
gem 'i18n'

gem 'redis', '~> 3.0'
gem 'redis-namespace', '~> 1.2'
gem 'dalli', '~> 2.1'
unless RUBY_PLATFORM == 'java'
  gem 'memcached', '~> 1.4'
end
gem 'memcache-client', '~> 1.8'
gem 'rake'
gem 'rack', '~> 1.4' # for ActiveSupport::Cache::FileStore of all things
