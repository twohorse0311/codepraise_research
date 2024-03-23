# fronze_string_literal: true

require 'roar/decorator'
require 'roar/json'

module CodePraise
  module Representer
    # Represent idiomaticity offense information
    class ReekOffense < Roar::Decorator
      include Roar::JSON

      property :smell_type
      property :message
      property :context
      property :lines
    end
  end
end