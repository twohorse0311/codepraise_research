# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'rubocop_offense_representer'

module CodePraise
  module Representer
    # Represents Idiomaticity Errors
    class Idiomaticity < Roar::Decorator
      include Roar::JSON

      property :offense_ratio
      property :cyclomatic_complexity
      property :level
      property :offense_count
      collection :offenses, extend: Representer::RubocopOffense, class: OpenStruct
    end
  end
end
