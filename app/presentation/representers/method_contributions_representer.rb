# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'contributor_representer'
require_relative 'credit_share_representer'

module CodePraise
  module Representer
    # Represents method in a file
    class MethodContributions < Roar::Decorator
      include Roar::JSON

      property :name
      property :line_credits
      property :line_percentage
      property :complexity
      property :type
    end
  end
end
