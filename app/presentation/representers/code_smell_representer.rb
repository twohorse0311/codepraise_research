# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'reek_offense_representer'

module CodePraise
  module Representer
    # Represents Idiomaticity Errors
    class CodeSmell < Roar::Decorator
      include Roar::JSON

      property :offense_ratio
      collection :offenses, extend: Representer::ReekOffense, class: OpenStruct
    end
  end
end
