# fronze_string_literal: true

require 'roar/decorator'
require 'roar/json'

module CodePraise
  module Representer
    # Represent Test Coverage Output
    class TestCoverage < Roar::Decorator
      include Roar::JSON

      property :coverage
      property :time
      property :message
    end
  end
end
