# frozen_string_literal: true

module CodePraise
  module Entity
    # Entity for folder contributions
    class FolderContributions < SimpleDelegator
      include Mixins::ContributionsCalculator

      attr_reader :path, :files, :repo_path

      def initialize(path:, files:, repo_path:)
        @path = path
        @files = files
        @repo_path = repo_path
        super(Types::HashedArrays.new)

        base_files.each { |file|   self[file.file_path.filename] = file }
        subfolders.each { |folder| self[folder.path] = folder }
      end

      def line_count
        files.map(&:line_count).reduce(&:+)
      end

      def total_line_credits
        files.map(&:total_line_credits).sum
      end

      def lines
        files.map(&:lines).reduce(&:+)
      end

      def test_coverage
        coverage_array = files.map(&:test_coverage).reject(&:nil?)

        return coverage_array[0].message if coverage_array[0]&.message

        covered_line_count = coverage_array.map(&:covered_line_count).sum
        missed_line_count = coverage_array.map(&:missed_line_count).sum

        return 0 if (covered_line_count + missed_line_count).zero?

        (covered_line_count.to_f / (covered_line_count + missed_line_count)).round(2)
      end

      def average_complexity
        files_complexity = files.map(&:complexity).reject(&:nil?)

        return 0 if files_complexity.count.zero?

        files_complexity.map(&:average).reduce(:+) / files_complexity.count
      end

      def base_files
        @base_files ||= files.select do |file|
          file.file_path.directory == comparitive_path
        end
      end

      def subfolders
        return @subfolders if @subfolders

        folders = nested_files
          .each_with_object(Types::HashedArrays.new) do |nested, lookup|
            subfolder = nested.file_path.folder_after(comparitive_path)
            lookup[subfolder] << nested
          end

        @subfolders = folders.map do |folder_name, folder_files|
          FolderContributions.new(path: folder_name, files: folder_files, repo_path: @repo_path)
        end
      end

      def any_subfolders?
        subfolders.count.positive?
      end

      def any_base_files?
        base_files.count.positive?
      end

      def credit_share
        return @credit_share if @credit_share

        @credit_share = files.map(&:credit_share).reduce(&:+)
        @credit_share.add_onwership_credit(self) if any_subfolders?
        @credit_share
      end

      def contributors
        credit_share.contributors
      end

      private

      def comparitive_path
        path.empty? ? path : path + '/'
      end

      def nested_files
        files - base_files
      end
    end
  end
end
