# frozen_string_literal: true
require './init.rb'
require 'database_cleaner/active_record'

# Helper to clean database during test runs
class DatabaseHelper
  def self.setup_database_cleaner
    DatabaseCleaner.allow_remote_database_url = true
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.start
  end

  def self.wipe_database
    CodePraise::Api.DB.run("SET session_replication_role = 'replica';")
    CodePraise::Database::ProjectOrm.map(&:destroy)
    CodePraise::Database::MemberOrm.map(&:destroy)
    CodePraise::Api.DB.run("SET session_replication_role = 'origin';")
    CodePraise::Api.mongo[:appraisals].drop
  end

  def self.reset_database
    CodePraise::Api.DB.run("DROP SCHEMA public CASCADE;
      CREATE SCHEMA public;
      GRANT ALL ON SCHEMA public TO postgres;
      GRANT ALL ON SCHEMA public TO public;
      COMMENT ON SCHEMA public IS 'standard public schema';")
    CodePraise::Api.mongo[:appraisals].drop
  end
end
