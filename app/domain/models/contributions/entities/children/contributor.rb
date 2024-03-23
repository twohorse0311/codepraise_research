# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module CodePraise
  module Entity
    # Contributor to a Git-based Project
    class Contributor < Dry::Struct
      include Dry.Types

      attribute :username,  Strict::String
      attribute :email,     Strict::String

      # Email address defines uniqueness
      def ==(other)
        email == other.email
      end

      def email_id
        return 'unknown' if email.nil? || email.empty?
        email.split('@').first.delete('.')
      end

      # Redefine hashing (hash uses eql?)
      alias eql? ==

      def hash
        email.hash
      end
    end
  end
end
