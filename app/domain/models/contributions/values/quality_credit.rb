# frozen_string_literal: true

module CodePraise
  module Value
    class QualityCredit < SimpleDelegator
      LEVEL_SCORE = {
        'A' => 3,
        'B' => 2,
        'C' => 1,
        'D' => 0,
        'E' => -1,
        'F' => -2
      }.freeze
      CREDITS = %i[complexity_credits idiomaticity_credits
                   documentation_credits test_credits].freeze

      def self.build_object(complexity = nil, idiomaticity = nil, comments = nil, test_cases = nil)
        obj = new
        add_complexity_credits(obj, complexity) if complexity
        add_idiomaticity_credits(obj, idiomaticity) if idiomaticity
        add_documentation_credits(obj, comments) if comments
        add_test_credits(obj, test_cases) if test_cases
        obj
      end

      def self.build_by_hash(hash)
        obj = new
        CREDITS.each do |credit|
          obj[credit] = hash[credit]
        end
        obj
      end

      def initialize
        super(Hash.new(Hash))
        CREDITS.each do |credit|
          self[credit] = Hash.new(0)
        end
      end

      CREDITS.each do |credit|
        define_method(credit) { self[credit] }
      end

      def credits
        CREDITS
      end

      private

      def self.add_complexity_credits(obj, complexity)
        complexity.method_complexities.each do |method_complexity|
          method_complexity.contributors.each do |email_id, percentage|
            obj[:complexity_credits][email_id] += method_complexity.complexity *
                                                  (percentage.to_f / 100)
          end
        end
      end

      def self.add_idiomaticity_credits(obj, idiomaticity)
        idiomaticity.offenses.each do |offense|
          offense.contributors.each do |email_id, line_count|
            obj[:idiomaticity_credits][email_id] += -1 * line_count
          end
        end
      end

      def self.add_documentation_credits(obj, comments)
        comments.each do |comment|
          comment.contributors.each do |email_id, line_count|
            credit = comment.is_documentation ? 1 : 0
            obj[:documentation_credits][email_id] += credit * line_count
          end
        end
      end

      def self.add_test_credits(obj, test_cases)
        test_cases.each do |test_case|
          test_case.contributors.each do |email_id, line_count|
            obj[:test_credits][email_id] += line_count
          end
        end
      end

      private_class_method :add_complexity_credits, :add_idiomaticity_credits,
                           :add_documentation_credits, :add_test_credits
    end
  end
end
