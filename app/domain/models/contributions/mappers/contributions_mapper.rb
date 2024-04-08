# frozen_string_literal: true
require 'benchmark'

module CodePraise
  module Mapper
    # Git contributions parsing and reporting services
    class Contributions
      def initialize(gitrepo, year)
        @gitrepo = gitrepo
        @year = year
      end

      def for_folder(folder_name)

        p "start blamereporter"
        blame = Git::BlameReporter.new(@gitrepo).folder_report(folder_name)
        p "end blamereporter"

        commits_result = nil
        commits_benchmark = Benchmark.measure do
          commits_result = commits
        end

        puts "計算 commit 時間： #{commits_benchmark}"

        Mapper::FolderContributions.new(
          folder_name,
          parse_file_reports(blame),
          @gitrepo.local.git_repo_path,
          # commits
          commits_result
        ).build_entity
      end

      def commits
        return @commits if @commits

        commit_report = GitCommit::CommitReporter.new(@gitrepo, @year)
        commits = commit_report.commits
        empty_commit = commit_report.empty_commit

        p "start building commit entities"
        @commits = commits.map do |commit|
          Mapper::Commit.new(commit, empty_commit).build_entity
        end
        p "end building commit entities"
        @commits
      end

      def parse_file_reports(blame_output)
        blame_output.map do |file_blame|
          name  = file_blame[0]
          blame = BlamePorcelain.parse_file_blame(file_blame[1])
          [name, blame]
        end.to_h
      end
    end
  end
end
