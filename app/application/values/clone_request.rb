# frozen_string_literal: true

module CodePraise
  module Value
    CloneRequest = Struct.new :project, :id, :update, :params
  end
end
