# frozen_string_literal: true

require 'date'

module CodePraise
  module SimpleCov
    # Read the coverage file and deserialize the result to Hash
    class TestCoverage
      COVERAGE_PATH = '/coverage/.resultset.json'

      def initialize(repo_path)
        path = repo_path + COVERAGE_PATH
        @coverage_hash = File.exist?(path) ? JSON.parse(File.read(path)) : nil
      end

      def coverage_report(file_path)
        {
          coverage: test_coverage(file_path),
          time: time,
          covered_line_count: covered_line_count(file_path),
          missed_line_count: missed_line_count(file_path)
        }
      end

      def coverage_hash
        return nil unless @coverage_hash

        @coverage_hash['RSpec']['coverage']
      end

      private

      def covered_line_count(file_path)
        return 0 unless @coverage_hash
        return 0 if test_array(file_path).nil? || test_array(file_path).empty?

        total_lines = test_array(file_path).reject(&:nil?)

        total_lines.reject(&:zero?).count
      end

      def missed_line_count(file_path)
        return 0 unless @coverage_hash
        return 0 if test_array(file_path).nil? || test_array(file_path).empty?

        total_lines = test_array(file_path).reject(&:nil?)

        total_lines.select(&:zero?).count
      end

      def time
        return nil unless @coverage_hash

        @time ||= Time.at(timestamp).to_time
      end

      def timestamp
        @coverage_hash['RSpec']['timestamp'].to_i
      end

      def project_path
        @project_path ||= longest_repeating_substring(coverage_hash.keys)
      end

      def test_array(file_path)
        path = project_path + file_path
        return nil unless coverage_hash[path]
        return coverage_hash[path] unless coverage_hash[path].include?('lines')

        coverage_hash[path]['lines']
      end

      def test_coverage(file_path)
        return nil unless @coverage_hash

        calculate_test_coverage(test_array(file_path))
      end

      # remove the project path and remain only the folder path
      def longest_repeating_substring(string_array)
        result = ''
        char_len = string_array[0].length
        char_len.times do |index|
          char_array = string_array.map { |string| string[index] }
          char_set = Set.new(char_array)
          result += char_set.first if char_set.length == 1
          break if char_set.length > 1
        end
        result
      end

      def calculate_test_coverage(coverage_array)
        return 0 if coverage_array.nil? || coverage_array.empty?

        total_lines = coverage_array.reject(&:nil?)

        return 0 if total_lines.empty?

        cover_lines = total_lines.reject(&:zero?)
        cover_lines.length.to_f / total_lines.length
      end
    end
  end
end
