# frozen_string_literal: true

module CodePraise
  module Git
    # Basic gateway to git shell commands
    class Command
      GIT = 'git'

      def initialize
        @command = []
        @options = []
        @params = []
        @redirects = []
      end

      def clone(git_url, path)
        @command = 'clone'
        @params = [git_url, path]
        self
      end

      def blame(filename, targit_path, porcelain: true)
        @command = "-C #{targit_path} blame"
        @options << 'line-porcelain' if porcelain
        @params = filename
        self
      end

      def log
        @command = 'log'
        self
      end

      def with_formatcommit
        @options << "pretty=format:'%H %cd'"
        self
      end

      def with_formatdate
        @options << 'date=format:%Y'
        self
      end

      def with_porcelain
        @options << 'line-porcelain'
        self
      end

      def with_progress
        @options << 'progress'
        self
      end

      def with_std_error
        @redirects << '2>&1'
        self
      end

      def options
        @options.map { |option| '--' + option }
      end

      def full_command
        [GIT, @command, options, @params, @redirects]
          .compact
          .flatten
          .join(' ')
      end

      def call
        `#{full_command}`
      end

      def capture_call
        IO.popen(full_command).each do |line|
          yield line if block_given?
        end
      end
    end
  end
end
