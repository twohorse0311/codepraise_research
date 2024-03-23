# frozen_string_literal: true

module CodePraise
  module Mapper
    # Find comment from LineContribution Entity
    module CommentParser
      MULTILINE = 2
      COMMENT = '#'

      # put the consecutive comments together
      def self.parse(line_entities)
        comment_lines = []
        line_entities.each_with_object([]) do |line_entity, comments|
          if comment?(line_entity)
            comment_lines.push(line_entity)
          elsif comment_lines.length.positive?
            comments.push(lines: comment_lines)
            comment_lines = []
          end
          comments
        end
      end

      def self.comment?(line_entity)
        line_entity.code.strip[0] == COMMENT
      end
    end
  end
end
