# frozen_string_literal: true

module CodePraise
  module Mapper
    # Parse the code style offense and calcualte the offense ratio for the file
    class CodeSmell
      def initialize(git_repo_path)
        @git_repo_path = git_repo_path
        @reek_reporter = CodePraise::Reek::Reporter.new(git_repo_path)
      end

      def build_entity(file_path, file_contributions)
        offenses = offenses(file_path, file_contributions)

        Entity::CodeSmell.new(
          offenses: offenses,
          offense_ratio: offense_ratio(offenses, file_contributions)
        )
      end

      private

      def offenses(file_path, file_contributions)
        code_smell_result = @reek_reporter.report

        return [] if code_smell_result.nil?

        
        code_smell_result.map do |offense_hash|
          Entity::ReekOffense.new(
            smell_type: offense_hash['smell_type'],
            message: offense_hash['message'],
            context: offense_hash['context'],
            lines: offense_hash['lines']
          )
        end
      end

      def contributors(offense_hash, file_contributions)
        lines = offense_hash['lines']
        contributors_hash = Hash.new(0)
        lines.each do |line|
          contributors_hash[file_contributions[line-1].contributor.email_id] += 1
        end
        contributors_hash
      end

      def offense_ratio(offenses, file_contributions)
        return 0.0 if offenses.empty? || file_contributions.empty?

        (offenses.map(&:lines).count.to_f / file_contributions.size)
          .round(2)
      end
    end
  end
end

## 計算整個 repo 的 reek 報告
# reek_report_org = `reek #{@git_repo_path} -f j`

## 用 JSON.parse 來處理（處理完會是一個 array）
# reek_report = JSON.parse(reek_report_org)

## 針對 array 用 map 的方式把大家的結果存成一個 hash array
# reek_offenses = []
# reek_report.each do |offense|
#   reek_offenses << {"lines": offense["lines"]}
# end

## 計算有幾行 code 觸發了 Code Smell 的問題（這裡可以問問看老師怎樣比較合理？）
# reek_offenses.map{|offense| offense[:lines].count}.reduce(0, :+)