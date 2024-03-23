# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper'

describe CodePraise::Entity::Complexity do
  DatabaseHelper.setup_database_cleaner
  COPS = %w[Style Layout Lint Metrics Naming Security].freeze

  before(:all) do
    @measurement_helper = MeasurementHelper.setup
    @idiomaticity = CodePraise::Mapper::Idiomaticity
      .new(@measurement_helper.repo_path)
      .build_entity(@measurement_helper.file_name,
                    @measurement_helper.file.lines)
  end

  after(:all) do
    DatabaseHelper.wipe_database
  end

  describe '#offenses' do
    it 'collect offense entities' do
      _(@idiomaticity.offenses[0]).must_be_kind_of CodePraise::Entity::RubocopOffense
    end

    describe 'Offense#type' do
      it 'show the type of offense' do
        type = @idiomaticity.offenses[0].type.split('/').first
        _(COPS).must_include type
      end
    end

    describe 'Offense#message' do
      it { _(@idiomaticity.offenses[0].message).must_be_kind_of String }
    end

    describe 'Offense#location' do
      it 'has start line and end line' do
        _(@idiomaticity.offenses[0].location.keys.sort)
          .must_equal %w[start_line last_line].sort
      end
    end

    describe 'Offense#line_count' do
      it { _(@idiomaticity.offenses[0].line_count).must_be :>, 0 }
    end

    describe 'Offense#contributors' do
      it 'show contributor of this offense' do
        _(@idiomaticity.offenses[0].contributors.keys[0])
          .must_be_kind_of String
        _(@idiomaticity.offenses[0].contributors.values[0])
          .must_be_kind_of Integer
      end
    end
  end

  describe '#offense_ratio' do
    it 'calculat offense ratio to line of code' do
      _(@idiomaticity.offense_ratio).must_be :>=, 0
    end
  end

  describe '#level' do
    it 'show the level of idiomaticity' do
      _(%w[A B C D E F]).must_include @idiomaticity.level
    end
  end
end
