# frozen_string_literal: true

module CodePraise
  module Mapper
    # Transform Flog raw data into Complexity Entity
    class Complexity
      def initialize(contributions, methods_contributions, repo_path)
        @contributions = contributions
        @methods_contributions = methods_contributions
        @repo_path = repo_path
      end

      def build_entity # 從這裡會撈出全部的 methond complexity 然後計算平均
        # 所以應該就是這裡可以直接塞整個檔案進來用 flog 算 complexity！

        return nil if methods.empty?

        # 可以透過這樣的方式直接把所有 code 都丟去給 flog -> 至少先取代下面的那個垃圾
        # test_ruby_code = @contributions.map(&:code).join("\n")
        # abc_metric(test_ruby_code).average
        # flog_result = `flog "#{@repo_path}"`
        # flog_result_split = flog_result.split("\n")
        # Entity::Complexity.new(
        #   average: flog_result_split[0].split(":")[0].to_i,
        #   method_complexities: flog_result_split[1].split(":")[0].strip.to_i
        # )

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
