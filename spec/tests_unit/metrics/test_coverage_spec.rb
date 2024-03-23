# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper'

describe CodePraise::Entity::TestCase do
  DatabaseHelper.setup_database_cleaner
  DatabaseHelper.wipe_database
  before do
    @measurement_helper = MeasurementHelper.setup
    path = @measurement_helper.git_repo.local.git_repo_path
    @coverage = CodePraise::SimpleCov::TestCoverage.new(path)
  end

  after do
    DatabaseHelper.wipe_database
  end

  # describe '#coverage_report' do
  #   it 'receive file path as parameter and report the test coverage of file' do
  #     file = @measurement_helper.file
  #     test_coverage = @coverage.coverage_report(file.file_path)
  #     _(test_coverage.keys.sort).must_equal %i[coverage datetime].sort
  #     _(test_coverage[:coverage]).must_be :>=, 0
  #   end
  # end
end
