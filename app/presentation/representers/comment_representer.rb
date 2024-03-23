# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module CodePraise
  module Representer
    # Representer for comment
    class Comment < Roar::Decorator
      include Roar::JSON

      property :type
      property :is_documentation
      property :readability
      property :contributors
    end
  end
end
