# frozen_string_literal: true

module CodePraise
  module Value
    class OwnershipCredit
      LEVEL_SCORE = {
        'A' => 3,
        'B' => 2,
        'C' => 1,
        'D' => 0,
        'E' => -1,
        'F' => -2
      }.freeze

      def initialize(folder)
        @folder = folder
      end

      def ownership_credits
        @ownership_credits ||= calculate_credits(@folder)
      end

      private

      def calculate_credits(folder)
        if folder.any_subfolders?
          subfolders_credits = folder.subfolders.map do |subfolder|
            calculate_credits(subfolder)
          end + [contributors_credit(folder.base_files, folder.contributors)]
          sum_array_hash(subfolders_credits)
        else
          contributors_credit(folder.base_files, folder.contributors)
        end
      end

      def sum_array_hash(array)
        array.each_with_object(Hash.new(0)) do |hash, result|
          hash.each do |key, value|
            result[key] += value
          end
        end
      end

      def sum_hash(hash1, hash2)
        all_keys(hash1, hash2).each_with_object({}) do |key, hash|
          hash[key] = hash1[key].to_i + hash2[key].to_i
        end
      end

      def all_keys(hash1, hash2)
        (hash1.keys + hash2.keys).uniq
      end

      def contributors_credit(files, contributors)
        contributors_percentage_hash = array_to_hash(files.map(&:line_percentage), contributors)
        contributors_percentage_hash.each do |k, v|
          nums = v.is_a?(Array) ? v : [v]
          contributors_percentage_hash[k] = credit(Math.coefficient_variation(nums))
        end
        contributors_percentage_hash
      end

      def array_to_hash(percentage_array, contributors)
        result = contributors.each_with_object({}) do |contributor, hash|
          hash[contributor.email_id] = []
        end
        percentage_array.each do |percentage_hash|
          result.each do |email_id, _|
            result[email_id] << percentage_hash[email_id].to_i
          end
        end
        result
      end

      def credit(coefficient_variation)
        level = variation_level(coefficient_variation)
        LEVEL_SCORE[level]
      end

      def variation_level(coefficient_variation)
        case coefficient_variation
        when 0..80
          'A'
        when 80..150
          'B'
        when 150..200
          'C'
        when 200..250
          'D'
        when 250..300
          'E'
        when 300..(1.0 / 0.0)
          'F'
        else
          'F'
        end
      end

    end
  end
end
