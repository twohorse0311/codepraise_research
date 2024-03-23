# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require_relative 'method_complexity'

module CodePraise
  module Entity
    # Complexity for file and methods of this file
    class Complexity < Dry::Struct
      include Dry.Types

      attribute :average, Coercible::Float
      attribute :method_complexities, Strict::Array.of(Entity::MethodComplexity).optional

      def level
        case average
        when 1..10
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
        else
          'F'
        end
      end
    end
  end
end
