# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper'

describe CodePraise::Entity::Complexity do
  DatabaseHelper.setup_database_cleaner

  before do
    @measurement_helper = MeasurementHelper.setup
    @complexity = CodePraise::Mapper::Complexity
      .new(@measurement_helper.file.lines,
           @measurement_helper.file.methods).build_entity
  end

  after do
    DatabaseHelper.wipe_database
  end

  describe '#average' do
    it 'calculate average ABC score for a file' do
      _(@complexity.average).must_be_kind_of Float
      _(@complexity.average).must_be :>=, 0
    end
  end

  describe '#method_complexities' do
    it 'collect MethodComplexity entity' do
      _(@complexity.method_complexities[0])
        .must_be_kind_of CodePraise::Entity::MethodComplexity
    end

    describe CodePraise::Entity::MethodComplexity do
      describe '#complexity' do
        it { _(@complexity.method_complexities[0].complexity).must_be :>=, 0 }
      end
      describe '#level' do
        it { _(%w[A B C D E F]).must_include @complexity.method_complexities[0].level }
      end
      describe '#contributors' do
        it 'show the contributor and his contribution in this method' do
          _(@complexity.method_complexities[0].contributors.keys[0])
            .must_be_kind_of String
          _(@complexity.method_complexities[0].contributors.values[0])
            .must_be_kind_of Integer
        end
      end
    end
  end

  describe '#level' do
    it 'show the level of complexity' do
      _(%w[A B C D E F]).must_include @complexity.level
    end
  end
end
