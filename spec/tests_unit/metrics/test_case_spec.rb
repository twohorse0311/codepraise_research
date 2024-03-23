# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper'

describe CodePraise::Entity::TestCase do
  DatabaseHelper.setup_database_cleaner
  DatabaseHelper.wipe_database

  before do
    @measurement_helper = MeasurementHelper.setup
    @test_cases = CodePraise::Mapper::TestCases
      .new(@measurement_helper.test_files[1].lines)
      .build_entities

  end

  after do
    DatabaseHelper.wipe_database
  end

  describe '#message' do
    it 'show the message of this test' do
      skip
      _(@test_cases[0].message).must_be_kind_of String
    end
  end
end
