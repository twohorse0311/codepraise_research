# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'contributor_representer'
require_relative 'credit_share_representer'
require_relative 'file_path_representer'
require_relative 'line_contribution_representer'
require_relative 'complexity_representer'
require_relative 'idiomaticity_representer'
require_relative 'code_smell_representer'
require_relative 'method_contributions_representer'
require_relative 'comment_representer'
require_relative 'test_case_representer'
require_relative 'test_coverage_representer'

module CodePraise
  module Representer
    # Represents folder summary about repo's folder
    class FileContributions < Roar::Decorator
      include Roar::JSON

      # basic information
      property :file_path, extend: Representer::FilePath, class: OpenStruct
      collection :contributors, extend: Representer::Contributor, class: OpenStruct
      # size information
      property :total_line_credits
      property :total_method_credits
      collection :methods, extend: Representer::MethodContributions, class: OpenStruct
      # quality information
      property :total_offenses
      property :total_test_expectation
      property :total_documentation
      property :has_documentation
      property :commits_count
      property :lines_count
      property :test_coverage, extend: Representer::TestCoverage, class: OpenStruct
      property :complexity, extend: Representer::Complexity, class: OpenStruct
      property :idiomaticity, extend: Representer::Idiomaticity, class: OpenStruct
      property :code_smells, extend: Representer::CodeSmell, class: OpenStruct
      collection :comments, extend: Representer::Comment, class: OpenStruct
      property :readability
      collection :test_cases, extend: Representer::TestCase, class: OpenStruct
      # ownership information
      property :line_percentage
      property :ownership_level
      # individual contribution
      property :credit_share, extend: Representer::CreditShare, class: OpenStruct
    end
  end
end
