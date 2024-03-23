# frozen_string_literal: true

require 'roda'
require_relative 'lib/init'

module CodePraise
  # Web App
  class Api < Roda
    include RouteHelpers

    plugin :request_headers
    plugin :halt
    plugin :all_verbs
    plugin :caching
    use Rack::MethodOverride

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "CodePraise API v1 at /api/v1/ in #{Api.environment} mode"

        result_response = Representer::HttpResponse.new(
          Value::Result.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        routing.on 'projects' do
          routing.on String, String do |owner_name, project_name|
            # GET /projects/{owner_name}/{project_name}[/folder_namepath/]
            routing.get do
              cache_control = Cache::Control.new(response)
              cache_control.turn_on if Env.new(Api).production?
              if cache_control.on?
                if_none_match = request.env['HTTP_IF_NONE_MATCH']
                redis = CodePraise::Cache::Client.new(CodePraise::Api.config)
                etag_key = "#{owner_name}_#{project_name}_etag"
                etag_value = redis.get(etag_key)

                if !if_none_match.nil? && !etag_value.nil? && if_none_match == etag_value
                  redis.quit
                  response.status = 304
                  return response.to_json
                end
              end

              request_id = [request.env, request.path, Time.now.to_f].hash

              path_request = ProjectRequestPath.new(
                owner_name, project_name, request
              )

              result = Service::AppraiseProject.new.call(
                requested: path_request,
                request_id: request_id,
                config: Api.config
              )

              # Never appraise
              if cache_control.on?
                if etag_value.nil?
                  etag_value = Base64.encode64(request_id.to_s)
                  redis.set(etag_key, etag_value)
                  redis.quit
                end
                response['Etag'] = etag_value
              end
              Representer::For.new(result).status_and_body(response)
            end

            # 2.7.3 ok
            # POST /projects/{owner_name}/{project_name}
            routing.post do
              result = Service::AddProject.new.call(
                owner_name: owner_name, project_name: project_name
              )

              Representer::For.new(result).status_and_body(response)
            rescue StandardError => e
              puts e.full_message
            end

            routing.put do
              request_id = [request.env, request.path, Time.now.to_f].hash

              path_request = ProjectRequestPath.new(
                owner_name, project_name, request
              )

              result = Service::AppraiseProject.new.call(
                requested: path_request,
                request_id: request_id,
                config: Api.config
              )

              redis = CodePraise::Cache::Client.new(CodePraise::Api.config)
              etag_key = "#{owner_name}_#{project_name}_etag"
              etag_value = Base64.encode64(request_id.to_s)
              redis.set(etag_key, etag_value)
              redis.quit
              Representer::For.new(result).status_and_body(response)
            end
          end

          routing.is do
            # GET /projects?list={base64 json array of project fullnames}
            routing.get do
              result = Service::ListProjects.new.call(
                list_request: Value::ListRequest.new(routing.params)
              )

              Representer::For.new(result).status_and_body(response)
            end
          end
        end
      end
    end
  end
end