# frozen_string_literal: true

require 'dry/transaction'

module CodePraise
  module Service
    # Analyzes contributions to a project
    class UpdateAppraisal
      include Dry::Transaction

      step :find_project_details
      step :check_project_eligibility
      step :request_cloning_worker
      step :appraise_contributions
      step :update_appraisal

      private

      NO_PROJ_ERR = 'Project not found'
      DB_ERR = 'Having trouble accessing the database'
      SIZE_ERR = 'Project too large to analyze'
      CLONE_ERR = 'Could not clone this project'
      NO_FOLDER_ERR = 'Could not find that folder'
      STORE_ERR = 'Could not store the project appraisal'

      # input hash keys required: :project, :requested, :config
      def find_project_details(input)
        input[:project] = Repository::For.klass(Entity::Project).find_full_name(
          input[:requested].owner_name, input[:requested].project_name
        )
        if input[:project]
          Success(input)
        else
          Failure(Value::Result.new(status: :not_found, message: NO_PROJ_ERR))
        end
      rescue StandardError
        Failure(Value::Result.new(status: :internal_error, message: DB_ERR))
      end

      def appraisal_exist?(input)
        owner_name = input[:requested].owner_name
        project_name = input[:requested].project_name
        appraisal = Repository::Appraisal.find(owner_name, project_name)
        if appraisal.nil? || input[:update] == 'true'
          Success(input)
        else
          Failure(Value::Result.new(status: :ok,
                                    message: appraisal
                                      .content(input[:requested].folder_name)))
        end
      end

      def check_project_eligibility(input)
        input[:gitrepo] = GitRepo.new(input[:project], input[:config])
        if input[:gitrepo].too_large?
          Failure(Value::Result.new(status: :bad_request, message: SIZE_ERR))
        else
          Success(input)
        end
      end

      def request_cloning_worker(input)
        return Success(input) if input[:gitrepo].exists_locally?

        notify_workers(input)
        Failure(
          Value::Result.new(status: :processing,
                            message: { request_id: input[:request_id] })
        )
      rescue StandardError => error
        puts [error.inspect, error.backtrace].flatten.join("\n")
        Failure(Value::Result.new(status: :internal_error, message: CLONE_ERR))
      end

      def appraise_contributions(input)
        contributions = Mapper::Contributions.new(input[:gitrepo])
        input[:folder] = contributions.for_folder(input[:requested].folder_name)
        input[:commits] = contributions.commits

        Value::ProjectFolderContributions.new(input[:project], input[:folder], input[:commits])
          .yield_self do |appraisal|
            input[:appraisal] = appraisal
            Success(input)
          end
      rescue StandardError
        Failure(Value::Result.new(status: :not_found, message: NO_FOLDER_ERR))
      end

      def update_appraisal(input)
        appraisal = Repository::Appraisal.update(appraisal_hash(input[:appraisal]))
        if appraisal.nil?
          Failure(Value::Result.new(status: :internal_error, message: STORE_ERR))
        else
          input[:gitrepo].delete
          Success(Value::Result.new(status: :ok,
                                    message: appraisal
                                      .content(input[:requested].folder_name)))
        end
      end

      def appraisal_hash(appraisal_entity)
        appraisal_representer = Representer::ProjectFolderContributions
          .new(appraisal_entity)
        JSON.parse(appraisal_representer.to_json)
      end

      def clone_request_json(input)
        Value::CloneRequest.new(input[:project], input[:request_id])
          .yield_self { |request| Representer::CloneRequest.new(request) }
          .yield_self(&:to_json)
      end

      def notify_workers(input)
        queues = [Api.config.CLONE_QUEUE_URL, Api.config.REPORT_QUEUE_URL]

        queues.each do |queue_url|
          Concurrent::Promise.execute do
            Messaging::Queue.new(queue_url, Api.config)
              .send(clone_request_json(input))
          end
        end
      end
    end
  end
end
