# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper'

describe CodePraise::Entity::FileContributions do
  DatabaseHelper.setup_database_cleaner
  DatabaseHelper.wipe_database

  before(:all) do
    @measurement_helper = MeasurementHelper.setup
    @method_contributions = CodePraise::Mapper::MethodContributions
      .new(@measurement_helper.file.lines).build_entity
    rescue Racc::ParseError
      binding.pry
  end

  after do
    DatabaseHelper.wipe_database
  end

  describe '#name' do
    it {
      _(@method_contributions[0].name).must_be_kind_of String }
  end

  describe '#lines' do
    it 'collect line entities' do
      _(@method_contributions[0].lines[0])
        .must_be_kind_of CodePraise::Entity::LineContribution
    end
  end

  describe '#line_credits' do
    it 'show the information of contributors' do
      skip
      _(@measurement_helper.contributors)
        .must_include @method_contributions[0].line_credits.keys[0]
      _(@method_contributions[0].line_credits.values.reduce(&:+))
        .must_be :<=, @method_contributions[0].lines.count
    end
  end
end
