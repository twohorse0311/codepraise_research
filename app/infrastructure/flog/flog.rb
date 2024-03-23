# frozen_string_literal: true

require 'flog'

module CodePraise
  module Complexity
    # Call the flog API and calculate flog score
    class FlogReporter
      def initialize(file_path)
        @file_path = file_path
      end

      def report
        return nil unless ruby_file?

        flog_result = flog_process

        {
          average: flog_result.average,
          methods: methods_complexity(flog_result.totals)
        }
      end

      # get flog score from pure ruby code
      def self.flog_code(code)
        flog = Flog.new(continue: true)
        flog.flog_ruby(code)
        flog.calculate_total_scores
        flog
      rescue StandardError
        Flog.new(continue: true)
      end

      private

      def flog_process
        flog = Flog.new(continue: true)
        flog.flog(*@file_path)
        flog
      end

      def ruby_file?
        File.extname(@file_path) == '.rb'
      end

      def methods_complexity(flog_totals)
        flog_totals.keys.each_with_object({}) do |key, result|
          result[only_method_name(key)] = flog_totals[key]
        end
      end

      def only_method_name(file_path)
        file_path.split('#').last
      end
    end
  end
end
