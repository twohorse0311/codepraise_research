# frozen_string_literal: true

module CodePraise
  module Mapper
    # Initialize the class and read the coverage file
    # Create TestCoverage entity for file
    class TestCoverage
      def initialize(repo_path)
        @repo_path = repo_path
      end

      def build_entity(file_path)
        coverage_hash = test_coverage.coverage_report(file_path)

        return nil unless coverage_hash

        Entity::TestCoverage.new(
          coverage: coverage_hash[:coverage],
          time: coverage_hash[:time],
          covered_line_count: coverage_hash[:covered_line_count],
          missed_line_count: coverage_hash[:missed_line_count]
        )
      end

      private

      def test_coverage
        @test_coverage ||= SimpleCov::TestCoverage.new(@repo_path)
      end
    end
  end
end
