# frozen_string_literal: true

require_relative 'quality_credit'
require_relative 'productivity_credit'
require_relative 'ownership_credit'

module CodePraise
  module Value
    # Value of credits shared by contributors for file, files, or folder
    class CreditShare < SimpleDelegator
      # rubocop:disable Style/RedundantSelf
      LEVEL_SCORE = {
        'A' => 10,
        'B' => 9,
        'C' => 8,
        'D' => 7,
        'E' => 6,
        'F' => 5
      }.freeze
      CREDITS = %i[quality_credit productivity_credit].freeze
      KLASS = {
        quality_credit: QualityCredit,
        productivity_credit: ProductivityCredit,
      }.freeze

      def self.build_object(file_contributions)
        obj = new
        obj[:quality_credit] = QualityCredit
          .build_object(file_contributions.complexity,
                        file_contributions.idiomaticity,
                        file_contributions.comments,
                        file_contributions.test_cases)
        obj[:productivity_credit] = ProductivityCredit
          .build_object(file_contributions.lines,
                        file_contributions.methods)
        obj[:contributors] = contributors(file_contributions.lines)
        obj
      end

      def self.contributors(line_contributions)
        line_contributions.each_with_object(Set.new) do |line, set|
          set << line.contributor
        end
      end

      def self.build_by_hash(hash, contributors)
        obj = new
        CREDITS.each do |credit|
          obj[credit] = KLASS[credit].build_by_hash(hash[credit])
        end
        obj[:contributors] = contributors
        obj
      end

      def initialize
        super({})
        CREDITS.each do |credit|
          self[credit] = KLASS[credit].new
        end
        self[:contributors] = Set.new
      end

      CREDITS.each do |credit|
        define_method(credit) { self[credit] }
      end

      def contributors
        self[:contributors]
      end

      def line_percentage
        productivity_credit.line_percentage
      end

      def +(other)
        raise TypeError, 'Must be CreditShare class' unless other.is_a?(CodePraise::Value::CreditShare)

        contributors = self.contributors + other.contributors
        result = {
          quality_credit: sum_credits(self[:quality_credit],
                                      other[:quality_credit]),
          productivity_credit: sum_credits(self[:productivity_credit],
                                           other[:productivity_credit])
        }
        CreditShare.build_by_hash(result, contributors)
      end

      def add_onwership_credit(folder)
        self[:ownership_credit] = OwnershipCredit.new(folder).ownership_credits
      end

      def ownership_credit
        self[:ownership_credit]
      end

      ### following methods allow two CreditShare objects to test equality
      def sorted_credit
        @share.to_a.sort_by { |a| a[0] }
      end

      def sorted_contributors
        @contributors.to_a.sort_by(&:username)
      end

      def state
        [sorted_credit, sorted_contributors]
      end

      def ==(other)
        other.class == self.class && other.state == self.state
      end

      alias eql? ==

      def hash
        state.hash
      end
      #############


      private

      def sum_credits(credit1, credit2)
        credit1.credits.each_with_object({}) do |credit, hash|
          hash[credit] = sum_hash(credit1[credit], credit2[credit])
        end
      end

      def sum_hash(hash1, hash2)
        all_keys(hash1, hash2)
          .each_with_object(Hash.new(0)) do |name, hash|
            hash[name] = hash1[name].to_f + hash2[name].to_f
          end
      end

      def all_keys(hash1, hash2)
        (hash1.keys + hash2.keys).uniq
      end

      def add_collective_ownership(ownership_score)
        ownership_score.each do |k, v|
          @collective_ownership[k] = {
            coefficient_variation: ownership_score[k],
            level: coefficient_variantion_level(ownership_score[k])
          }
        end
      end

      def coefficient_variantion_level(coefficient_variantion)
        case coefficient_variantion
        when 0..50
          'A'
        when 50..100
          'B'
        when 100..150
          'C'
        when 150..200
          'D'
        when 200..250
          'E'
        when 250..(1.0 / 0.0)
          'F'
        end
      end

      # rubocop:enable Style/RedundantSelf
    end
  end
end
