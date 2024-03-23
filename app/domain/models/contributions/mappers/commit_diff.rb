# frozen_string_literal: true

module CodePraise
  module Mapper
    # Parse the file changes from git diff information
    module CommitDiff
      def self.parser(diff)
        diff_files = diff.stats[:files].reject { |k, _| k.nil? }
        diff_files.keys.map do |key|
          {
            path: key,
            name: file_name(key),
            addition: diff_files[key][:insertions],
            deletion: diff_files[key][:deletions]
          }
        end
      end

      def self.file_name(file_path)
        file_path.split('/').last
      end
    end
  end
end
