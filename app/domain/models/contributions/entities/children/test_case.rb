# frozen_string_literal: true

require_relative 'line_contribution'
require 'dry-types'
require 'dry-struct'

module CodePraise
  module Entity
    class TestCase < Dry::Struct
      include Dry.Types

      attribute :message, Strict::String
      attribute :lines, Array.of(LineContribution)
      attribute :top_describe, Strict::String.optional

      def expectation_count
        lines.select do |line|
          expectation?(line.code)
        end.count
      end

      def contributors
        lines.each_with_object({}) do |line, hash|
          hash[line.contributor.email_id] ||= 0
          hash[line.contributor.email_id] += 1 if expectation?(line.code)
        end
      end

      def key_words
        keywords = message.scan(/([A-Z].+)\:|\(([A-Z].+)\)/).flatten.join(' ')

        if keywords.empty?
          ['None']
        else
          remove_symbol(keywords).split(' ')
        end
      end

      def remove_symbol(keywords)
        keywords.gsub(/\)|\(|\]|\[/, '')
      end

      private

      def expectation?(code)
        !(code =~ /\.must|\.wont|\.to|\.not_to/).nil?
      end
    end
  end
end
