# frozen_string_literal: true

module CodePraise
  module Mapper
    # Transform Flog raw data into Complexity Entity
    class Complexity
      def initialize(contributions, methods_contributions)
        @contributions = contributions
        @methods_contributions = methods_contributions
      end

      def build_entity
        return nil if methods.empty?

        Entity::Complexity.new(
          average: average(methods),
          method_complexities: methods
        )
      end

      private

      def methods
        methods_complexity + none_complexity
      end

      def average(methods)
        methods.map(&:complexity).reduce(&:+) / methods.length
      end

      def methods_complexity
        @methods_contributions.map do |method_contributions|
          ruby_code = method_contributions.lines.map(&:code).join("\n")
          complexity = abc_metric(ruby_code)

          method_complexity_entity(complexity.average,
                                   method_contributions.line_percentage,
                                   method_contributions.name)
        end
      end

      def none_complexity
        none = @contributions - @methods_contributions.map(&:lines).flatten

        code = none.map(&:code).join("\n")
        complexity = abc_metric(code)

        [method_complexity_entity(complexity.average,
                                  none_contributors(none),
                                  'none')]
      end

      def method_complexity_entity(complexity, contributors, name)
        CodePraise::Entity::MethodComplexity.new(
          complexity: complexity,
          contributors: contributors,
          name: name
        )
      end

      def none_contributors(none)
        none.each_with_object(Hash.new(0)) do |line, hash|
          hash[line.contributor.email_id] += 1
        end
      end

      def abc_metric(code)
        flog_reporter = CodePraise::Complexity::FlogReporter

        flog_reporter.flog_code(code) if code
      end
    end
  end
end
