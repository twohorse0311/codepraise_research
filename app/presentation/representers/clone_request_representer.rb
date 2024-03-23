# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'project_representer'

# Represents essential Repo information for API output
module CodePraise
  module Representer
    # Representer object for project clone requests
    class CloneRequest < Roar::Decorator
      include Roar::JSON

      property :project, extend: Project, class: OpenStruct
      property :id
      property :update
    end
  end
end
