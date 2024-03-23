# frozen_string_literal: true

require_relative 'command'

module CodePraise
  module Reek
    # Implement the reek command
    # Deserialize the reek result to Hash
    class Reporter
      def initialize(git_repo_path)
        @command = Command.new
          .target(git_repo_path)
          .format('json')
      end

      def report
        JSON.parse(call)
      end

      private

      def call
        @call ||= `#{@command.full_command}`
      end
    end
  end
end
