# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'contributor_representer'
require_relative 'file_change_representer'

module CodePraise
  module Representer
    # Representer for commit entity
    class Commit < Roar::Decorator
      include Roar::JSON

      property :committer, extend: Representer::Contributor, class: OpenStruct
      property :sha
      property :message
      property :date
      property :size
      property :total_additions
      property :total_deletions
      property :total_files
      property :total_addition_credits
      property :total_deletion_credits
      property :total_credited_files
      collection :file_changes, extend: Representer::FileChange, class: OpenStruct
    end
  end
end
