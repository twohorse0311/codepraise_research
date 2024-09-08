# frozen_string_literal: true

module CodePraise
  module Entity
    # Entity for file contributions
    class FileContributions
      include Mixins::ContributionsCalculator

      DOT = '\.'
      LINE_END = '$'
      WANTED_EXTENSION = %w[rb js css html slim md coffee].join('|')
      EXTENSION_REGEX = /#{DOT}(#{WANTED_EXTENSION})#{LINE_END}/.freeze

      
      attr_reader :file_path, :lines, :complexity, :idiomaticity, :code_smells, :methods,
                  :comments, :readability, :test_cases, :commits_count, :test_coverage

      def initialize(file_path:, lines:, complexity:, idiomaticity:, code_smells:, methods:, comments:, readability:, test_cases:, commits_count:, test_coverage:)
        @file_path = Value::FilePath.new(file_path)
        @lines = lines
        @complexity = complexity
        @idiomaticity = idiomaticity
        @code_smells = code_smells
        @methods = methods
        @comments = comments
        @readability = readability
        @test_cases = test_cases
        @commits_count = commits_count
        @test_coverage = test_coverage
      end

      

      def has_documentation
        return false if @comments.nil?

        @comments.select(&:is_documentation).length.positive?
      end

      def lines_by(contributor)
        lines.select { |line| line.contributor == contributor }
      end

      def credits_for(contributor)
        lines_by(contributor).map(&:credit).sum
      end

      def credit_share
        return Value::CreditShare.new if not_wanted

        @credit_share ||= CodePraise::Value::CreditShare.build_object(self)
      end

      def contributors
        credit_share.contributors
      end

      def lines_count
        @lines.count
      end

      private

      def ruby_file?
        File.extname(file_path.filename) == '.rb'
      end

      def not_wanted
        !wanted
      end

      def wanted
        file_path.filename.match(EXTENSION_REGEX)
      end
    end
  end
end
