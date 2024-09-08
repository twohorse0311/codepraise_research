# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'contributor_representer'
require_relative 'credit_share_representer'
require_relative 'file_contributions_representer'
require_relative 'line_contribution_representer'

module CodePraise
  module Representer
    # Represents folder summary about repo's folder
    class FolderContributionsResearch < Roar::Decorator

      include Roar::JSON

      # basic information
      property :total_readability
      property :total_code_smell
      property :total_complexity
      property :total_cyclomatic_complexity
      property :total_idiomaticity
    end
  end
end
