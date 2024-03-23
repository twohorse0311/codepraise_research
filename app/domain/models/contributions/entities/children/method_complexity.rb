# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module CodePraise
  module Entity
    # Entity for a single method complexity by a team-member
    class MethodComplexity < Dry::Struct
      include Dry.Types

      attribute :name,         Strict::String
      attribute :complexity,   Coercible::Float
      attribute :contributors, Strict::Hash.optional

      def level
        case complexity
        when 0..10
          'A'
        when 10..20
          'B'
        when 20..40
          'C'
        when 40..60
          'D'
        when 60..100
          'E'
        when 100..(1.0 / 0.0)
          'F'
        end
      end
    end
  end
end
