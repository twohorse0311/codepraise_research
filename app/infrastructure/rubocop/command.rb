# frozen_string_literal: true

module CodePraise
  module Rubocop
    # Use object to operate rubocop command
    class Command
      FORMAT = {
        'json' => 'j'
      }.freeze

      RUBOCOP = 'rubocop'

      def initialize
        @format = ''
        @except = []
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

      def except(cop)
        @except << cop
        self
      end

      def with_stderr_output
        @redirects << '2>&1'
        self
      end

      def full_command
        [RUBOCOP, @target, options, @redirects].join(' ')
      end

      private

      def options
        option = "-f #{@format}"
        except = @except.join(',')
        option += " --except #{except}" unless except.empty?
        option
      end
    end
  end
end
