# frozen_string_literal: false

require 'dry-types'
require 'dry-struct'

module CodePraise
  module Entity
    # Domain entity for team members
    class CommitInfo < Dry::Struct
      include Dry.Types

      attribute :id,        Integer.optional
      attribute :sha, Strict::String
      attribute :commit_date, Strict::Integer

      def to_attr_hash
        to_hash.except(:id)
      end
    end
  end
end
