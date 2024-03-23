# frozen_string_literal: true

require_relative 'projects_representer'
require_relative 'project_folder_contributions_representer'
require_relative 'project_representer'
require_relative 'http_response_representer'
require_relative 'appraisal_representer'

module CodePraise
  module Representer
    # Representer Generator is used for creating representer dynamically
    class For
      REP_KLASS = {
        Value::ProjectsList               => ProjectsList,
        Value::ProjectFolderContributions => ProjectFolderContributions,
        Entity::Project                   => Project,
        Entity::Appraisal                 => Appraisal,
        String                            => HttpResponse,
        Hash                              => HttpResponse
      }.freeze

      attr_reader :status_rep, :body_rep

      def initialize(result)
        value = result.failure? ? result.failure : result.value!
        @status_rep = HttpResponse.new(value)
        representer = REP_KLASS[value.message.class]
        @body_rep = representer == HttpResponse ? representer.new(value) : representer.new(value.message)
      end

      def http_status_code
        @status_rep.http_status_code
      end

      def to_json
        @body_rep.to_json
      end

      def status_and_body(response)
        response.status = http_status_code
        to_json
      end
    end
  end
end
