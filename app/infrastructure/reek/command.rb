# frozen_string_literal: true

module CodePraise
  module Reek
    # Use object to operate rubocop command
    class Command
      FORMAT = {
        'json' => 'j'
      }.freeze

      REEK = 'reek'

      def initialize
        @format = ''
        @redirects = []
        @target = ''
      end

      def format(output_format)
        @format = FORMAT[output_format]
        self
      end

      def target(file_path)
        @target = file_path == '/' ? '' : file_path
        self
      end

      def with_stderr_output
        @redirects << '2>&1'
        self
      end

      def full_command
        [REEK, @target, options, @redirects].join(' ')
      end

      private

      def options
        "-f #{@format}"
      end
    end
  end
end
