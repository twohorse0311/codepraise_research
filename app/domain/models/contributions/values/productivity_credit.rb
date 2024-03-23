# frozen_string_literal: true

module CodePraise
  module Value
    class ProductivityCredit < SimpleDelegator
      CREDITS = %i[line_credits method_credits].freeze

      def self.build_object(line_contributions=nil, method_contributions=nil)
        obj = new
        add_line_credits(obj, line_contributions) if line_contributions
        add_method_credits(obj, method_contributions) if method_contributions
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
        super({})
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

      def line_percentage
        sum = line_credits.values.reduce(&:+)
        line_credits.keys.each_with_object({}) do |email_id, hash|
          hash[email_id] = sum.zero? ? 0 : ((line_credits[email_id].to_f / sum) * 100).round
        end
      end

      private

      def self.add_line_credits(obj, line_contributions)
        line_contributions.each do |line|
          obj[:line_credits][line.contributor.email_id] += line.credit
        end
      end

      def self.add_method_credits(obj, method_contributions)
        method_contributions.each do |method|
          method.line_percentage.each do |k, v|
            obj[:method_credits][k] ||= 0
            obj[:method_credits][k] += 1.0 * (v.to_f / 100)
          end
        end
      end

      private_class_method :add_line_credits, :add_method_credits
    end
  end
end
