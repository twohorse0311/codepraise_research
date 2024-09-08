# frozen_string_literal: true

require_relative '../init'
require_relative 'project_clone'
require 'fileutils'
require 'ruby-prof'


module Appraisal
  # Encapuslate all useful method for appraisal worker
  class Service
    attr_reader :cache

    def initialize(project, reporter, gitrepo, request_id, params)
      @project = project
      @reporter = reporter
      @gitrepo = gitrepo
      @request_id = request_id
      @params = params
    end

    def find_or_init_cache(project_name, owner_name)
      @cache = CodePraise::Repository::Appraisal.find_or_create_by( # 存進 mongoDB
        project_name:,
        owner_name:
      )
      @reporter.publish(CloneMonitor.progress('STARTED'), 'processing', @request_id)
      @cache
    end

    def setup_channel_id(request_id)
      data = { request_id: }
      @cache = CodePraise::Repository::Appraisal
               .update(id: @cache.id, data:)
    end

    def clone_project
      puts "clone: #{@gitrepo.id}"
      return p 'skip clonning' if @params['clone_over'] == '0'

      @gitrepo.clone_locally do |line|
        @reporter.publish(CloneMonitor.progress(line), 'cloning', @request_id)
      end

      rubocop_config = "/Users/twohorse/Desktop/repostore_temp/#{@gitrepo.id}/.rubocop.yml"
      File.delete(rubocop_config) if File.exist?(rubocop_config)

      reek_config = "/Users/twohorse/Desktop/repostore_temp/#{@gitrepo.id}/.reek.yml"
      File.delete(reek_config) if File.exist?(reek_config)
      
    end

    def store_commits(commit_year)
      return "repo doesn't exist locally" unless @gitrepo.exists_locally?

      @commit_year = commit_year
      @reporter.publish(CloneMonitor.percent(commit_year.to_s), 'storing commits', @request_id)
      @log_cache = CodePraise::Git::LogReporter.new(@gitrepo, commit_year)
      p 'start to log commit'
      last_commit = @log_cache.log_commits # get the last commit of the year
      # last_commit = {sha: "123"} # get the last commit of the year

      if last_commit.nil?
        @log_cache.delete_copy_file
        return nil
      end

      @sha = last_commit[:sha]

      # @cache_specific_commit = CodePraise::Repository::Appraisal.find_or_create_by( # 存進 mongoDB
      #   { project_name: @project.name,
      #     owner_name: @project.owner.username,
      #     commit_year: }
      # )
      p 'start to checkout to commit'
      p "sha: #{@sha}"
      @log_cache.checkout_commit(@sha)
      # commit_mapper.get_commit_entity(commit_year) # get commit entity
    end

    def appraise_project
      # @reporter.publish(CloneMonitor.progress('Appraising'), 'appraising', @request_id)
      rubocop_config = "/Users/twohorse/Desktop/repostore_temp/#{@gitrepo.id}_#{@commit_year}/.rubocop.yml"
      File.delete(rubocop_config) if File.exist?(rubocop_config)

      reek_config = "/Users/twohorse/Desktop/repostore_temp/#{@gitrepo.id}_#{@commit_year}/.reek.yml"
      File.delete(reek_config) if File.exist?(reek_config)
      contributions = CodePraise::Mapper::Contributions.new(@gitrepo, @commit_year)

      p 'start to calculate folder_contributions'

      folder_contributions = nil
      folder_contributions_benchmark = Benchmark.measure do
        folder_contributions = contributions.for_folder('')
      end

      puts "整個 folder_contributions_benchmark 時間： #{folder_contributions_benchmark}"
      
      # profile = RubyProf::Profile.new

      # profile.start
      # folder_contributions = contributions.for_folder('')
      # result = profile.stop

      
      # printer = RubyProf::GraphHtmlPrinter.new(result)
      # File.open("/Users/twohorse/Desktop/repostore_analysis/file.html", "w") do |file|
      #   printer.print(file)
      # end

      # printer1 = RubyProf::FlatPrinter.new(result)
      # File.open("/Users/twohorse/Desktop/repostore_analysis/file.txt", "w") do |file|
      #   printer1.print(file)
      # end
      commit_analysis = contributions.commits
      @project_folder_contribution = CodePraise::Value::ProjectFolderContributions
                                     .new(@project, folder_contributions, commit_analysis)
      
      # @reporter.publish(CloneMonitor.progress('Appraised'), 'appraised', @request_id)
      # @gitrepo.delete
    end

    def store_appraisal_cache(commit_year)
      return false unless @project_folder_contribution

      contributions_hash = folder_contributions_hash
      contributions_hash['folder'] = @project_folder_contribution.folder
      contributions_hash['commits'] = @project_folder_contribution.commits

      data = { appraisal: contributions_hash }
      
      target_path = "/Users/twohorse/Desktop/repostore_analysis/#{@project.owner.username}_#{@project.name}_#{commit_year}.json"
      # target_path = "/Volumes/external_disk/temp/repostore/#{@project.name}_#{@project.owner.username}_#{commit_year}.json"
      # target_path = "app/infrastructure/git/repostore/#{@project.name}_#{@project.owner.username}_#{commit_year}.json"
      # 确保目标目录存在，不存在则创建
      FileUtils.mkdir_p(File.dirname(target_path))
      p "-----#{target_path}-----"
      File.write(target_path, JSON.pretty_generate(contributions_hash))
      @log_cache.delete_copy_file

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
        .new(@project_folder_contribution).then do |representer|
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
