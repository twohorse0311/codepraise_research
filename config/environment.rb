# frozen_string_literal: true

require 'rack/cache'
require 'redis-rack-cache'
require 'roda'
require 'figaro'
require 'mongo'
require 'shoryuken'

module CodePraise
  # Environment-specific configuration
  class Api < Roda
    plugin :environments

    configure do
      Figaro.application = Figaro::Application.new(
        environment: environment.to_s,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load

      def self.config
        Figaro.env
      end
    end

    configure :development, :test, :data do
      require 'pry'

      Mongo::Logger.logger.level = Logger::FATAL
        Shoryuken.logger.level = Logger::FATAL
      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./init.rb'
      end
    end

    configure :development, :test, :data do
      ENV['MONGODB_URL'] = 'mongodb://' + config.MONGO_URL
    end

    configure :development, :data do
      puts 'RUNNING IN DEVELOPMENT OR DATA MODE'
      Mongo::Logger.logger.level = Logger::FATAL

      use Rack::Cache,
          verbose: true,
          metastore: config.REDISCLOUD_URL + '/0/metastore',
          entitystore: config.REDISCLOUD_URL + '/0/entitystore'
    end

    configure :production do
      # Use deployment platform's DATABASE_URL environment variable
      puts 'RUNNING IN PRODUCTION MODE'
      Mongo::Logger.logger.level = Logger::FATAL

      use Rack::Cache,
          verbose: true,
          metastore: config.REDISCLOUD_URL + '/0/metastore',
          entitystore: config.REDISCLOUD_URL + '/0/entitystore'
    end

    configure :app_test do
      require_relative '../spec/helpers/vcr_helper.rb'
      VcrHelper.setup_vcr
      VcrHelper.configure_vcr_for_github(recording: :none)
    end

    configure do
      require 'sequel'
      DB = Sequel.connect(ENV['DATABASE_URL'])

      def self.DB # rubocop:disable Naming/MethodName
        DB
      end

      require 'mongo'
      MONGO = Mongo::Client.new(ENV['MONGODB_URL'])

      def self.mongo
        MONGO
      end

      require 'flipper-mongo'
      def self.flipper
        collection = mongo['flipper']
        adapter = Flipper::Adapters::Mongo.new(collection)
        Flipper.new(adapter)
      end
    end
  end
end
