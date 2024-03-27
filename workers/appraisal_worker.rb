# frozen_string_literal: true

require_relative '../init'
require_relative 'progress_reporter'
require_relative 'project_clone'
require_relative 'cache_state'
require_relative 'appraisal_service'
require 'figaro'
require 'shoryuken'
require 'json'
require 'ostruct'

MUTEX = Mutex.new

module Appraisal
  # Shoryuken worker class to clone repos in parallel

  class RepoNotFoundError < StandardError;end

  class Worker
    Figaro.application = Figaro::Application.new(
      environment: ENV['RACK_ENV'] || 'development',
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load

    def self.config
      Figaro.env
    end

    def self.environment
      ENV['RACK_ENV'] || 'development'
    end

    def self.logger
      file = 'log/logs.log'
      File.new(file, 'w+') unless File.exist?(file)
      log_file = File.open(file, 'a')

      Logger.new(log_file)
    end

    Shoryuken.sqs_client = Aws::SQS::Client.new(
      access_key_id: config.AWS_ACCESS_KEY_ID,
      secret_access_key: config.AWS_SECRET_ACCESS_KEY,
      region: config.AWS_REGION
    )

    include Shoryuken::Worker
    # Shoryuken.sqs_client_receive_message_opts = { max_number_of_messages: 1 }

    shoryuken_options queue: config.CLONE_QUEUE_URL, auto_visibility_timeout: true, retry: 3

    def perform(sqs_msg, request)
      @url = JSON.parse(request, object_class: OpenStruct).project.http_url
      puts "Project: #{@url}"

      project, reporter, request_id, update, params = setup_job(request)
      gitrepo = CodePraise::GitRepo.new(project, Worker.config)
      service = Service.new(project, reporter, gitrepo, request_id, params)
      cache = service.find_or_init_cache(project.name, project.owner.username)

      service.setup_channel_id(request_id.to_s) unless cache.request_id

      cache_state = CacheState.new(cache)
      cache_state.update_state('init') if update

      if cache_state.cloning?
        service.switch_channel(cache.request_id)
      else
        cache_state.update_state('cloning')
        service.clone_project
        cache_state.update_state('cloned')
      end

      # require 'pry'
      # binding.pry

      # commit_mapper = CodePraise::Github::CommitMapper.new(gitrepo)
      commits = 2014.downto(2014).map do |commit_year|

        result = service.store_commits(commit_year)
        raise RepoNotFoundError, "Repo doesn't exist locally" if result == "repo doesn't exist locally"
        next nil if result.nil?

        MUTEX.synchronize do
          puts "appraise #{gitrepo.id}"
          cache_state.update_state('appraising')
          service.appraise_project
          cache_state.update_state('appraised')
          puts "done #{gitrepo.id}}"
        end
        service.store_appraisal_cache(commit_year)
        # commit_mapper.get_commit_entity(commit_year)
      end.compact

      service.checkout_back

      # if cache_state.cloned? && !cache_state.appraising?
      #   MUTEX.synchronize do
      #     puts "appraise #{gitrepo.id}"
      #     cache_state.update_state('appraising')
      #     service.appraise_project
      #     cache_state.update_state('appraised')
      #     puts "done #{gitrepo.id}}"
      #   end
      # else
      #   service.switch_channel(cache.request_id)
      # end

      # if cache_state.appraised? && !cache_state.stored?
      #   service.store_appraisal_cache
      #   cache_state.update_state('stored')
      # else
      #   service.switch_channel(cache.request_id)
      # end

      sqs_msg.delete

      each_second(15) do
        reporter.publish(CloneMonitor.finished_percent, 'stored', request_id)
      end
    rescue StandardError, RepoNotFoundError => e
      error_message = "Exception: #{@url}\n Message: #{e.full_message}"
      puts error_message
      # Worker.logger.error(error_message) unless Worker.environment == 'production'

      data = { project_name: project.name, owner_name: project.owner.username }
      CodePraise::Repository::Appraisal.delete(data)
      sqs_msg.change_visibility(visibility_timeout: 0)
    end

    private

    def setup_job(request)
      clone_request = CodePraise::Representer::CloneRequest
                      .new(OpenStruct.new).from_json(request) 
      [clone_request.project,
       ProgressReporter.new(Worker.config, clone_request.id),
       clone_request.id, clone_request.update, clone_request.params]
    end

    def each_second(seconds)
      seconds.times do
        sleep(1)
        yield if block_given?
      end
    end
  end
end
