# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module CodePraise
  module Entity
    class ReekOffense < Dry::Struct
      include Dry.Types

      attribute :smell_type,   Strict::String
      attribute :message,      Strict::String
      attribute :context,      Strict::String
      attribute :lines,        Strict::Array.of(Strict::Integer)
    end
  end
end
