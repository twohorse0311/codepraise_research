# frozen_string_literal: true

require 'git'
require 'open3'

module GitCommit
  # This Object Use Git gem to get all commits
  class CommitReporter
    EMPTY_SHA = '4b825dc642cb6eb9a060e54bf8d69288fbee4904'

    def initialize(gitrepo, year)
      @local = gitrepo.local
      @year = year
      @path = @local.git_repo_path + "_#{@year}"
      # @git = Git.open(@path)
    end

    # def commit(sha)
    #   @git.log(sha)
    # end

    def commits(since = nil)
      # commits = get_all_commits
      # commits = commits.since(since) unless since.nil?
      # commits
      start_date = "#{@year}-01-01"
      end_date = "#{@year}-12-31"
      commit_count_command = "git -C #{@path} rev-list --count --since=#{start_date} --until=#{end_date} HEAD"
      commit_stdout, commit_stderr, commit_status = Open3.capture3(commit_count_command)
      commit_count = commit_stdout.strip.to_i if commit_status.success?
      git_log_command = "git -C #{@path} log --since=#{start_date} --until=#{end_date} --pretty=tformat: --numstat"
      log_stdout, log_stderr, log_status = Open3.capture3(git_log_command)
      if log_status.success?
        added_lines = 0
        deleted_lines = 0

        log_stdout.each_line do |line|
          added, deleted, = line.split("\t").map(&:to_i)
          added_lines += added
          deleted_lines += deleted
        end
      end
      
      {
        commit_count:,
        added_lines:,
        deleted_lines:
      }
    end

    def empty_commit
      @git.gcommit(EMPTY_SHA)
    end

    private

    def get_all_commits
      # n = 500
      # until @git.log(n).size < n do
      #   n += 500
      # end
      # @git.log(n)
      start_date = "#{@year}-01-01"
      end_date = "#{@year}-12-31"
      @git.log.since(start_date).until(end_date)
    end
  end
end
