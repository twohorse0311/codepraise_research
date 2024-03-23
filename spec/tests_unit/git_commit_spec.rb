# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'
require_relative '../helpers/database_helper'
require_relative '../helpers/measurement_helper'


describe GitCommit::CommitReporter do
  DatabaseHelper.setup_database_cleaner

  before do
    @measurement_helper = MeasurementHelper.setup
    @commit_reporter = GitCommit::CommitReporter.new(@measurement_helper.git_repo)
  end

  after do
    DatabaseHelper.wipe_database
  end

end
