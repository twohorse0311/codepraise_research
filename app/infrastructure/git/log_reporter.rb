# frozen_string_literal: true

require 'base64'
require 'git'

require_relative 'git'

module CodePraise
  module Git
    # USAGE:
    #   load 'infrastructure/gitrepo/gitrepo.rb'
    #   origin = Git::RemoteGitRepo.new('git@github.com:soumyaray/YPBT-app.git')
    #   local = Git::LocalGitRepo.new(origin, 'infrastructure/gitrepo/repostore')

    # Manage remote Git repository for cloning
    class LogReporter
      attr_reader :path

      def initialize(git_repo)
        @git_repo = git_repo
        @git = ::Git.open(@git_repo.repo_local_path)
      end

      def latest_commit
        @git.log.first.sha
      end

      def full_command
        Git::Command.new
          .log
          .with_formatcommit
          .with_formatdate
          .full_command
      end

      def checkout_commit(commit_sha)
        @git.checkout(commit_sha)
      end

      def log_commits(commit_year)
        start_date = "#{commit_year}-01-01"
        end_date = "#{commit_year}-12-31"
        commits = @git.log.since(start_date).until(end_date)
        last_commit = commits.first # 获取该年份的最后一次提交
        return nil if last_commit.nil?

        @sha = last_commit.sha
        { year: commit_year, sha: @sha }
      end
    end
  end
end
