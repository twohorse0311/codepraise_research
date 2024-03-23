# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module CodePraise
  module Entity
    class RubocopOffense < Dry::Struct
      include Dry.Types

      attribute :type,         Strict::String
      attribute :message,      Strict::String
      attribute :location,     Strict::Hash
      attribute :line_count,   Strict::Integer
      attribute :contributors, Strict::Hash
    end
  end
end
