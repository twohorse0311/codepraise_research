# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper.rb'

describe 'Contributor-Level Measurement' do
  DatabaseHelper.setup_database_cleaner

  before(:all) do
    @measurement_helper = MeasurementHelper.setup
    @folder_contributions = @measurement_helper.folder_contributions
    @commit_contributions = @measurement_helper.commits
    @project = @measurement_helper.project
    @appraisal = CodePraise::Value::ProjectFolderContributions
      .new(@project, @folder_contributions, @commit_contributions)
      .yield_self do |value|
        CodePraise::Representer::ProjectFolderContributions
        .new(value)
      end
  end

  after(:all) do
    DatabaseHelper.wipe_database
  end

  it 'should render json format' do
    _(@appraisal.to_json).must_be_kind_of String
  end
end
