# frozen_string_literal: true

require_relative 'command'

module CodePraise
  module Rubocop
    # Implement the rubocop command
    # Deserialize the rubocop result to Hash
    class Reporter
      def initialize(git_repo_path)
        @git_repo_path = git_repo_path
        @command = Command.new
                          .target(git_repo_path)
                          .except('')
                          .format('json')
      end

      def report
        @report ||= JSON.parse(call)['files'].each_with_object({}) do |file, hash|
          hash[file['path']] = file['offenses']
        end
      rescue JSON::ParserError
        puts 'JSON Parsing error occurred, starting pry for debugging...'
        @report = { 'path' => @git_repo_path, 'offenses' => [] }
      end

      private

      def call
        @call ||= `#{@command.full_command}`
      end
    end
  end
end
