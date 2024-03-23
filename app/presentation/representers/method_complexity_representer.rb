# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module CodePraise
  module Representer
    # Represents complexity for method
    class MethodComplexity < Roar::Decorator
      include Roar::JSON

      property :name
      property :complexity
      property :contributors
    end
  end
end
