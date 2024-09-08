# frozen_string_literal: true

module CodePraise
  module Mapper
    # Summarizes a single file's contributions by team members
    class FileContributions
      def initialize(file_report, repo_path, idiomaticity_mapper, code_smell_mapper, commits, test_coverage_mapper)
        @file_report = file_report
        @repo_path = repo_path
        @idiomaticity_mapper = idiomaticity_mapper
        @code_smell_mapper = code_smell_mapper
        @test_coverage_mapper = test_coverage_mapper
        @commits = commits
      end

      def build_entity
        all_comments = comments

        Entity::FileContributions.new(
          file_path: filename,
          lines: contributions,
          complexity: complexity,
          idiomaticity: idiomaticity,
          code_smells: code_smells,
          methods: methods,
          comments: all_comments,
          readability: readability(all_comments),
          test_cases: test_cases,
          commits_count: commits_count,
          test_coverage: test_coverage
        )
      end

      private

      def filename
        @file_report[0]
      end

      def contributions
        summarize_line_reports(@file_report[1])
      end

      def complexity # 這裡會丟入所有的 method complexity，但有必要嗎？？
        return nil unless ruby_file?

        Mapper::Complexity.new(contributions, methods, @repo_path).build_entity
      end

      def idiomaticity
        return nil unless ruby_file?

        @idiomaticity_mapper.build_entity(file_path, contributions)
      end

      def code_smells
        return nil unless ruby_file?

        @code_smell_mapper.build_entity(file_path, contributions)
      end

      def test_coverage
        return nil unless ruby_file?

        @test_coverage_mapper.build_entity(file_path)
      end

      def methods # 會用 flog 計算 method complexity（但需要嗎？）
        return [] unless ruby_file?

        MethodContributions.new(contributions).build_entity
      rescue StandardError => e
        puts "Parse Method Error: #{e.full_message}"
        []
      end

      def comments
        return [] unless ruby_file?

        Comments.new(contributions).build_entities
      end

      def readability(comments)
        doc_comments = comments.select(&:is_documentation)
        return 0 if doc_comments.empty?

        doc_comments.map(&:readability).sum / doc_comments.length.to_f
      end

      def test_cases
        return [] unless test_files? && ruby_file?

        TestCases.new(contributions).build_entities
      rescue StandardError => e
        puts "Parse Test Cases Error: #{e.full_message}"
        []
      end

      def summarize_line_reports(line_reports)
        line_reports.map.with_index do |report, line_index|
          Entity::LineContribution.new(
            contributor: contributor_from(report),
            code: strip_leading_tab(report['code']),
            time: Time.at(report['author-time'].to_i),
            number: index_to_number(line_index)
          )
        end
      end

      def file_path
        Value::FilePath.new(filename)
      end

      def ruby_file?
        File.extname(@file_report[0]) == '.rb'
      end

      def test_files?
        !(filename =~ /spec|test/).nil?
      end

      def commits_count
        @commits.select do |commit|
          change_file(commit)
        end.length
      end

      def change_file(commit)
        commit.file_changes.select do |file_change|
          file_change.path == filename
        end.length.positive?
      end

      def contributor_from(report)
        Entity::Contributor.new(
          username: report['author'],
          email: bare_email(report['author-mail'])
        )
      end

      # remove angle brackets <..> around email addresses
      def bare_email(email)
        email[1..-2]
      end

      # remove leading tab from git blame code output
      def strip_leading_tab(code_line)
        code_line[1..-1]
      end

      # add 1 to line indexes to make them line numbers
      def index_to_number(index)
        index + 1
      end
    end
  end
end
