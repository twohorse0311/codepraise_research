# frozen_string_literal: true

require 'benchmark'
require 'textstat'
require 'open3'

module CodePraise
  module Mapper
    # Git contributions parsing and reporting services
    class Contributions
      def initialize(gitrepo, year)
        @gitrepo = gitrepo
        @year = year
        @full_path = "#{@gitrepo.local.git_repo_path}_#{@year}"
      end

      def for_folder(_folder_name)
        # p 'start reporter'
        # blame = Git::BlameReporter.new(@gitrepo, @year).folder_report(folder_name)
        # p 'end blamereporter'

        commits_result = nil
        commits_benchmark = Benchmark.measure do
          commits_result = commits
        end

        puts "計算 commit 時間： #{commits_benchmark}"

        # fc_entity = Mapper::FolderContributions.new(
        #   folder_name,
        #   parse_file_reports(blame), # 解析 blame
        #   @full_path,
        #   # @gitrepo.local.git_repo_path,
        #   # commits
        #   commits_result
        # ).build_entity
        # total_readability = fc_entity.files.map(&:readability).reduce(0, :+)
        total_readability = total_readability_caculator
        total_code_smell = total_code_smell_calculator
        total_complexity = total_complexity_calculator
        rubocop_report = rubocop_reporter
        total_line_of_code = total_line_of_code_calculator
        # fc_entity

        {
          total_readability:,
          total_code_smell:,
          total_complexity: total_complexity[:method_complexities],
          total_complexity_average: total_complexity[:average],
          total_cyclomatic_complexity: rubocop_report[:total_cyclomatic_complexity],
          total_idiomaticity: rubocop_report[:total_idiomaticity],
          total_line_of_code:
        }
      end

      def commits
        # return @commits if @commits

        commit_report = GitCommit::CommitReporter.new(@gitrepo, @year)
        commit_report.commits
        # empty_commit = commit_report.empty_commit

        # p 'start building commit entities'
        # @commits = commits.map do |commit|
        #   Mapper::Commit.new(commit, empty_commit).build_entity
        # end
        # p 'end building commit entities'
      end

      def parse_file_reports(blame_output)
        blame_output.map do |file_blame|
          name  = file_blame[0]
          blame = BlamePorcelain.parse_file_blame(file_blame[1])
          [name, blame]
        end.to_h
      end

      def total_code_smell_calculator
        puts 'reek 計算中...'
        # 計算整個 repo 的 reek 報告
        reek_report_org = `reek #{@full_path} -f j`

        # 用 JSON.parse 來處理（處理完會是一個 array）
        reek_report = JSON.parse(reek_report_org)

        # 針對 array 用 map 的方式把大家的結果存成一個 hash array
        reek_offenses = []
        reek_report.each do |offense|
          reek_offenses << {
            lines: offense['lines'],
            type: offense['smell_type'],
            source: offense['source']
          }
        end

        # 計算有幾行 code 觸發了 Code Smell 的問題（這裡可以問問看老師怎樣比較合理？） # 要記得補一個 uniq

        offenses_count = reek_offenses.uniq.map { |offense| offense[:lines].count }.reduce(0, :+)
        offenses_count.to_f
      end

      def total_line_of_code_calculator
        puts '計算 line of code'
        `find #{@full_path} -name "*.rb" -exec grep -v "^\s*$" {} + | wc -l`.split("\n")[0].strip.to_i
      end

      def total_complexity_calculator
        puts 'flog 計算中...'

        stdout, stderr, status = Open3.capture3("flog #{@full_path} --continue")
        flog_result = stdout

        if stderr.include?('no files or')
          puts "#{@full_path} 沒東西可以跑 flog ㄛ～ 通通給個 0 分"
          return {
            method_complexities: 0,
            average: 0
          }
        elsif flog_result == ''
          puts "#{@full_path} 分析 flog 出事囉～拿下一年的來擋一下"
          binding.pry
          last_year_analysis = File.read("/Users/twohorse/Desktop/repostore_analysis/#{@gitrepo.local.git_repo_path.split('/')[5]}_#{@year + 1}.json")
          last_year_data = JSON.parse(last_year_analysis)['folder']
          last_year_total_complexity = last_year_data['total_complexity']
          last_year_total_complexity_average = last_year_data['total_complexity_average']

          return {
            method_complexities: last_year_total_complexity,
            average: last_year_total_complexity_average
          }
        end

        flog_result_split = flog_result.split("\n")
        {
          method_complexities: flog_result_split[0].split(':')[0].to_i,
          average: flog_result_split[1].split(':')[0].strip.to_i
        }
      end

      def rubocop_reporter
        puts 'rubocop 計算中...'
        # 計算整個 file 的 rubocop 狀況
        config_file = '/Users/twohorse/Desktop/codepraise_research/.rubocop.yml'
        test = `rubocop #{@full_path}  --config #{config_file} --format j`

        return { total_cyclomatic_complexity: 0, total_idiomaticity: 0 } if test == ''

        # 用 JSON.parse() 把剛剛的結果轉成 hash
        test = JSON.parse(test)

        # 把每個 file 的 offenses 都抓出來
        test_report = test['files'].each_with_object({}) do |file, hash|
          hash[file['path']] = file['offenses']
        end

        # 把所有 offenses 以 {"type": report["cop_name"], "message": report["message"]} 的方式存進去一個空的 array
        offenses = []
        test_report.each do |_key, value|
          value.each do |report|
            offenses << {
              type: report['cop_name'],
              message: report['message'],
              line_count: report['location']['last_line'] - report['location']['start_line'] + 1
            }
          end
        end

        # 此時的 empty_array 內容物幾乎等於不是 Entity 的 offenses（上面的結果）

        # 計算 Cyclomatic Complexity 的分數

        cyclomatic_complexity = offenses.select { |offense| offense[:type] == 'Metrics/CyclomaticComplexity' }
                                        .map { |entity| entity[:message].match(%r{\[(\d+)/})&.captures&.first.to_i || 0 }
                                        .reduce(0, :+)

        # 計算 Idiomaticity
        # 所有 offenses 的行數
        idiomaticity = offenses.reject { |offense| offense[:type].include? 'Metrics/' }.count

        # 所有檔案的行數
        {
          total_cyclomatic_complexity: cyclomatic_complexity,
          total_idiomaticity: idiomaticity
        }
      end

      def total_readability_caculator
        all_comment = `grep -rh '^# .\\+' #{@full_path}`
        all_comment.force_encoding('UTF-8')
        cleaned_comment = all_comment.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        TextStat.gunning_fog(cleaned_comment)
      end
    end
  end
end
