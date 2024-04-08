# frozen_string_literal: true

require 'git'

module GitCommit
  # This Object Use Git gem to get all commits
  class CommitReporter
    EMPTY_SHA = '4b825dc642cb6eb9a060e54bf8d69288fbee4904'

    def initialize(gitrepo, year)
      @local = gitrepo.local
      @year = year
      path = @local.git_repo_path + "_#{@year}"
      @git = Git.open(path)
    end

    def commit(sha)
      @git.log(sha)
    end

    def commits(since=nil)
      commits = get_all_commits
      commits = commits.since(since) unless since.nil?
      commits
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