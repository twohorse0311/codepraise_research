# frozen_string_literal: true

require_relative '../init.rb'
require_relative 'project_clone'

module Appraisal
  # Encapuslate all useful method for appraisal worker
  class Service
    attr_reader :cache

    @representer

    def initialize(project, reporter, gitrepo, request_id)
      @project = project
      @reporter = reporter
      @gitrepo = gitrepo
      @request_id = request_id
    end

    def find_or_init_cache(project_name, owner_name)
      @cache = CodePraise::Repository::Appraisal.find_or_create_by( # 存進 mongoDB
        project_name: project_name,
        owner_name: owner_name
      )
      @reporter.publish(CloneMonitor.progress('STARTED'), 'processing', @request_id)
      @cache
    end

    def setup_channel_id(request_id)
      data = { request_id: request_id }
      @cache = CodePraise::Repository::Appraisal
        .update(id: @cache.id, data: data)
    end

    def clone_project
      puts "clone: #{@gitrepo.id}"
      @gitrepo.clone_locally do |line|
        @reporter.publish(CloneMonitor.progress(line), 'cloning', @request_id)
      end

      rubocop_config = "app/infrastructure/git/repostore/#{@gitrepo.id}/.rubocop.yml"
      File.delete(rubocop_config) if File.exist?(rubocop_config)

      reek_config = "app/infrastructure/git/repostore/#{@gitrepo.id}/.reek.yml"
      File.delete(reek_config) if File.exist?(reek_config)
    end

    def store_commits(commit_year)
      @commit_year = commit_year
      @reporter.publish(CloneMonitor.percent(commit_year.to_s), 'storing commits', @request_id)
      log_cache = CodePraise::Git::LogReporter.new(@gitrepo)
      last_commit = log_cache.log_commits(commit_year) # get the last commit of the year
      
      return nil if last_commit.nil?

      @sha = last_commit[:sha]
      
      @cache_specific_commit = CodePraise::Repository::Appraisal.find_or_create_by( # 存進 mongoDB
        { project_name: @project.name,
          owner_name: @project.owner.username,
          commit_year: }
      )
      log_cache.checkout_commit(@sha)
      # commit_mapper.get_commit_entity(commit_year) # get commit entity
    end

    def appraise_project
      # @reporter.publish(CloneMonitor.progress('Appraising'), 'appraising', @request_id)
      contributions = CodePraise::Mapper::Contributions.new(@gitrepo)
      folder_contributions = contributions.for_folder('')
      commit_contributions = contributions.commits
      @project_folder_contribution = CodePraise::Value::ProjectFolderContributions
        .new(@project, folder_contributions, commit_contributions)
      # @reporter.publish(CloneMonitor.progress('Appraised'), 'appraised', @request_id)
      # @gitrepo.delete
    end

    def store_appraisal_cache(commit_year)
      return false unless @project_folder_contribution

      contributions_hash = folder_contributions_hash

      data = { appraisal: contributions_hash }

      
      # target_path = "/Volumes/external_disk/temp/repostore/#{@project.name}_#{@project.owner.username}_#{commit_year}.json"
      target_path = "app/infrastructure/git/repostore/#{@project.name}_#{@project.owner.username}_#{commit_year}.json"
      
      # 确保目标目录存在，不存在则创建
      FileUtils.mkdir_p(File.dirname(target_path))
      p "-----#{target_path}-----"
      p contributions_hash
      require 'pry'
      binding.pry
      File.write(target_path, JSON.pretty_generate(contributions_hash))
      File.write(target_path, contributions_hash)

      # CodePraise::Repository::Appraisal
      #   .update(id: @cache_specific_commit.id, data: data)
      # each_second(15) do
      #   @reporter.publish(CloneMonitor.finished_percent, 'stored', @request_id)
      # end
    end

    def switch_channel(channel_id)
      @reporter.publish('0', 'switch', channel_id)
    end

    private

    def folder_contributions_hash
      CodePraise::Representer::ProjectFolderContributions
        .new(@project_folder_contribution).yield_self do |representer|
          @representer = representer
          JSON.parse(representer.to_json)
        end
    end

    def each_second(seconds)
      seconds.times do
        sleep(1)
        yield if block_given?
      end
    end
  end
end
