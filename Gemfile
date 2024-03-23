# frozen_string_literal: true

source 'https://rubygems.org'
# source 'http://mirror.ops.rhcloud.com/mirror/ruby/'
ruby File.read('.ruby-version').strip

# PRESENTATION LAYER
gem 'multi_json', '~> 1.13'
gem 'roar', '~> 1.1'

# APPLICATION LAYER
# Web application related
gem 'figaro', '~> 1.2'
gem 'puma', '~> 5.5'
gem 'rack-cache', '~> 1.13'
gem 'redis', '~> 4.5'
gem 'redis-rack-cache', '~> 2.2'
gem 'roda', '~> 3.50'

# Controllers and services
gem 'dry-monads', '~> 1.4'
gem 'dry-transaction', '~> 0.13'
# gem 'dry-validation', '~> 0.13.3'

# DOMAIN LAYER
gem 'dry-struct', '~> 1.4'
gem 'dry-types', '~> 1.5'

# INFRASTRUCTURE LAYER
# Networking
gem 'http', '~> 5.0'

# Queues
gem 'aws-sdk-sqs', '~> 1.46'

# Database
gem 'hirb', '~> 0.7'
gem 'sequel', '~> 5.50'

# Ruby AST unparser
gem 'parser', '~> 3.1'

# Git Operation by using git object
gem 'git', '~> 1.9'

# MongoDB Driver
gem 'mongo', '~> 2.17'

# QUALITY
gem 'flog', '~> 4.6'
gem 'rubocop', '~> 1.39'
gem 'rubocop-performance', '~> 1.12'
gem 'reek', '~> 6.0'

# Switcher
gem 'flipper-mongo'

group :development, :test do
  gem 'database_cleaner', '~> 2.0'
  gem 'factory_bot', '~> 6.2'
  gem 'sqlite3', '~> 1.4'
end

gem 'pg', '~> 1.2'

# WORKERS
gem 'faye', '~> 1.4'
gem 'shoryuken', '~> 5.3'

# DEBUGGING
group :development, :test do
  gem 'pry-rescue', '~> 1.5'
  gem 'pry-stack_explorer', '~> 0.6'
end

# TESTING
group :test do
  gem 'minitest', '~> 5.14'
  gem 'minitest-hooks', '~> 1.5'
  gem 'minitest-rg', '~> 5.2'
  gem 'simplecov', '~> 0.21'
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~> 3.13'
end

gem 'rack-test' # can also be used to diagnose production

# UTILITIES
gem 'pry', '~> 0.14'
gem 'rake', '~> 13.0'
gem 'travis', '~> 1.10'

group :development, :test do
  gem 'rerun', '~> 0.13'
end
