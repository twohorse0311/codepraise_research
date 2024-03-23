# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module CodePraise
  module Entity
    class TestCoverage < Dry::Struct
      include Dry.Types

      attribute :coverage, Coercible::Float.optional
      attribute :time, Strict::Time.optional
      attribute :covered_line_count, Strict::Integer.optional
      attribute :missed_line_count, Strict::Integer.optional

      def message
        'Please include coverage/.result.set.json in your repo' unless coverage
      end
    end
  end
end
