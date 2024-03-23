# frozen_string_literal: true

require_relative 'line_contribution'
require 'dry-types'
require 'dry-struct'

module CodePraise
  module Entity
    # Entity for a single method contributed by a team-member
    class MethodContribution < Dry::Struct
      include Dry.Types

      attribute :name, Coercible::String
      attribute :lines, Array.of(LineContribution)
      attribute :type, Strict::String
      attribute :complexity, Coercible::Float.optional

      def line_credits
        productivity_credit.line_credits
      end

      def line_percentage
        productivity_credit.line_percentage
      end

      private

      def productivity_credit
        @productivity_credit ||= Value::ProductivityCredit.build_object(lines)
      end
    end
  end
end
