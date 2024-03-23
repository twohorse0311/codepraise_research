# frozen_string_literal: true

module CodePraise
  # Maps over local and remote git repo infrastructure
  class GitRepo
    MAX_SIZE = 20000 # for cloning, analysis, summaries, etc.

    class Errors
      NoGitRepoFound = Class.new(StandardError)
      TooLargeToClone = Class.new(StandardError)
      CannotOverwriteLocalGitRepo = Class.new(StandardError)
    end

    def initialize(project, config)
      @remote = Git::RemoteGitRepo.new(project.http_url)
      @local = Git::LocalGitRepo.new(@remote, config.REPOSTORE_PATH)
      @size = project.size
    end

    def repo_local_path
      @local.path
    end

    def id
      @remote.unique_id
    end

    def local
      if exists_locally?
        @local
      else
        puts "error: #{@local.git_repo_path} / #{Dir.pwd}"
        raise(Errors::NoGitRepoFound)
      end
      # exists_locally? ? @local : raise(Errors::NoGitRepoFound)
    end

    def delete
      @local.delete
    end

    def too_large?
      return false unless CodePraise::Api.flipper[:clone_size_check].enabled?

      @size > MAX_SIZE
    end

    def exists_locally?
      @local.exists?
    end

    def clone_locally
      raise Errors::TooLargeToClone if too_large?
      @local.delete if exists_locally?

      @local.clone_remote { |line| yield line if block_given? }
    end
  end
end
