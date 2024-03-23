# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require_relative '../children/contributor'

module CodePraise
  module Entity
    # Entity for a single line of code contributed by a team-member
    class Commit < Dry::Struct
      include Dry.Types

      DOT = '\.'
      LINE_END = '$'
      WANTED_EXTENSION = %w[rb js css html slim md coffee scss].join('|')
      EXTENSION_REGEX = /#{DOT}(#{WANTED_EXTENSION})#{LINE_END}/.freeze

      attribute :committer,     Contributor
      attribute :sha,           Strict::String
      attribute :date,          Strict::Time
      attribute :size,          Strict::Integer
      attribute :message,       Strict::String
      attribute :file_changes,  Strict::Array.of(FileChange)

      def total_additions
        file_changes.map(&:addition).reduce(&:+)
      end

      def total_deletions
        file_changes.map(&:deletion).reduce(&:+)
      end

      def total_files
        file_changes.count
      end

      def total_credited_files
        wanted_files.count
      end

      def total_addition_credits
        wanted_files.map(&:addition).reduce(&:+).to_i
      end

      def total_deletion_credits
        wanted_files.map(&:deletion).reduce(&:+).to_i
      end

      private

      def wanted(file)
        file.path.match(EXTENSION_REGEX)
      end

      def wanted_files
        file_changes.select do |file|
          wanted(file)
        end
      end
    end
  end
end
