# frozen_string_literal: true

require 'base64'
require 'git'
require 'fileutils'

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

      def initialize(git_repo, year)
        @git_repo = git_repo
        @year = year
        @copy_path = @git_repo.repo_local_path + "_#{@year}"
        FileUtils.cp_r(@git_repo.repo_local_path, @copy_path)
      end

      def delete_copy_file
        FileUtils.rm_r(@copy_path)
      end

      def full_command
        Git::Command.new
                    .log
                    .with_formatcommit
                    .with_formatdate
                    .full_command
      end

      def checkout_commit(commit_sha)
        puts "-----#{commit_sha}-----"
        `git -C #{@copy_path} checkout #{commit_sha}`
      end

      def log_commits
        start_date = "#{@year}-01-01"
        end_date = "#{@year}-12-31"
        git_command = "git -C #{@copy_path} log --since=#{start_date} --until=#{end_date} --pretty=format:'%H' -n 1"
        last_commit = `#{git_command}`

        return nil if last_commit == ''

        @sha = last_commit
        { year: @year, sha: @sha }
      end
    end
  end
end
