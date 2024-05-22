# frozen_string_literal: true

require_relative 'comment_parser'

module CodePraise
  module Mapper
    # Transform Flog raw data into Complexity Entity
    class Comments
      def initialize(line_entities)
        @line_entities = line_entities
      end

      def build_entities
        comments.map do |comment|
          is_documentation = true # documentation?(comment[:lines])
          # is_documentation ? binding.pry : true
          readability = is_documentation ? readability(comment[:lines]) : 0

          Entity::Comment.new(
            lines: comment[:lines],
            is_documentation: is_documentation,
            readability: readability
          )
        end
      end

      private

      def comments
        @comments ||= CommentParser.parse(@line_entities)
      end

      def documentation?(comment_entiies)
        next_line = (comment_entiies.last.number + 1).yield_self do |no|
          @line_entities.select do |line_entity|
            line_entity.number == no
          end.first
        end

        method_or_class(next_line.code)
      end

      def method_or_class(code)
        !(code.strip =~ /^class|^def/).nil?
      end

      def readability(comment_entiies)
        fog_indices = comment_entiies.map { |comment| gunning_fog(comment.code) }
        average_fog_index = fog_indices.inject(0, :+).to_f / fog_indices.size
        average_fog_index.ceil
      end

      def gunning_fog(text)
        sentences = text.split(/\.|\?|!/)
        words = text.split
        words_per_sentence = words.size.to_f / sentences.size

        complex_words = 0
        words.each do |word|
          complex_words += 1 if syllables(word) >= 3
        end

        fog_index = 0.4 * (words_per_sentence + 100 * (complex_words.to_f / words.size))
        fog_index.ceil
      end

      # Helper method to count the number of syllables in a word
      def syllables(word)
        word.downcase!
        return 1 if word.length <= 3
        word.sub!(/(?:[^laeiouy]es|ed|[^laeiouy]e)$/, '')
        word.sub!(/^y/, '')
        word.scan(/[aeiouy]{1,2}/).size
      end
    end
  end
end
