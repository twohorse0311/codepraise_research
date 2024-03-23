# frozen_string_literal: true

module CodePraise
  module Mixins
    # line credit calculation methods
    module ContributionsCalculator
      def ownership_level
        max_percentage = line_percentage.values.max
        case max_percentage
        when 25..40
          'A'
        when 40..60
          'B'
        else
          'C'
        end
      end

      def line_percentage
        credit_share.line_percentage
      end

      def total_line_credits
        sum_credits(credit_share.productivity_credit.line_credits)
      end

      def total_method_credits
        sum_credits(credit_share.productivity_credit.method_credits)
      end

      def total_offenses
        sum_credits(credit_share.quality_credit.idiomaticity_credits) * -1
      end

      def total_test_expectation
        sum_credits(credit_share.quality_credit.test_credits)
      end

      def total_documentation
        sum_credits(credit_share.quality_credit.documentation_credits)
      end

      private

      def sum_credits(credit_hash)
        credit_hash.values.sum.round
      end
    end
  end
end
