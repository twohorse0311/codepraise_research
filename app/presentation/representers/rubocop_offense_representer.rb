# fronze_string_literal: true

require 'roar/decorator'
require 'roar/json'

module CodePraise
  module Representer
    # Represent idiomaticity offense information
    class RubocopOffense < Roar::Decorator
      include Roar::JSON

      property :type
      property :message
      property :location
      property :line_count
      property :contributors
    end
  end
end