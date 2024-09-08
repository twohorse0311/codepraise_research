# frozen_string_literal: false

module CodePraise
  # Provides access to project commit
  module Github
    class CommitMapper
      def initialize(git_repo)
        @git_repo = git_repo
        @path = @git_repo.repo_local_path
      end

      def get_commit_entity(year)
        commit = Git::LogReporter.new(@git_repo, year).log_commits
        return nil if commit.nil?

        build_entity(commit)
      end

      def build_entity(commit)
        DataMapper.new(commit).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(commit)
          @commit = commit
        end

        def build_entity
          Entity::CommitInfo.new(
            id: nil,
            sha:,
            commit_date:
          )
        end

        private

        def sha
          @commit[:sha]
        end

        def commit_date
          @commit[:year]
        end
      end
    end
  end
end
