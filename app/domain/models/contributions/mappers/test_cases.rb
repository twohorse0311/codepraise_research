# frozen_string_literal: true

require_relative 'test_case_parser'

module CodePraise
  module Mapper
    # Parse the test case and find its LineContributions entities
    class TestCases
      def initialize(line_entities)
        @line_entities = line_entities
      end

      def build_entities
        test_cases.map do |test_case|
          Entity::TestCase.new(
            message: test_case[:message],
            lines: lines(test_case[:first_line], test_case[:last_line]),
            top_describe: test_case[:top_describe]
          )
        end
      end

      private

      def test_cases
        TestCaseParser.parse(@line_entities.map(&:code).join("\n"))
      end

      def lines(first_line, last_line)
        @line_entities[first_line - 1..last_line - 1]
      end
    end
  end
end
