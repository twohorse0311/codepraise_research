# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require_relative 'rubocop_offense'

module CodePraise
  module Entity
    class Idiomaticity < Dry::Struct
      include Dry.Types

      attribute :offenses, Strict::Array.of(Entity::RubocopOffense).optional
      attribute :offense_ratio, Strict::Float
      attribute :cyclomatic_complexity, Strict::Integer

      def offense_count
        offenses.length
      end

      def level
        case offense_ratio * 100
        when 0..5
          'A'
        when 5..10
          'B'
        when 10..20
          'C'
        when 20..30
          'D'
        when 30..40
          'E'
        when 40..(1.0 / 0.0)
          'F'
        end
      end
    end
  end
end
