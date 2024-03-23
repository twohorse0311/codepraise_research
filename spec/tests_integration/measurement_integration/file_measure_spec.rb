# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper.rb'

describe 'File-Level Measurement' do
  DatabaseHelper.setup_database_cleaner

  before do
    @measurement_helper = MeasurementHelper.setup
    @folder_contributions = @measurement_helper.folder_contributions
    @file = @measurement_helper.file
  end

  after do
    DatabaseHelper.wipe_database
  end

  describe CodePraise::Entity::FileContributions do
    describe 'Measure File Quality' do
      it 'should calculate average complexity and give a complexity level' do
        _(@file.complexity.average).wont_be_nil
        _(%w[A B C D E F]).must_include @file.complexity.level
      end

      it 'should calculate total offenses of idiomaticity' do
        _(@file.idiomaticity.offense_ratio).wont_be_nil
        _(@file.idiomaticity.offense_count).must_be :>=, 0
      end

      it 'should verify if file has documentation' do
        _([true, false]).must_include @file.has_documentation
      end

      it 'should count number of commit of this file' do
        _(@file.commits_count).must_be :>, 0
      end
    end

    describe 'Measure File Size' do
      it 'should calculate number of line of code' do
        _(@file.total_line_credits).must_be :>=, 0
      end

      it 'should calculate number of method' do
        _(@file.methods.length).must_be :>=, 0
      end

      it 'should calculate number of comment' do
        _(@file.comments).must_be_kind_of Array
      end
    end

    describe 'Code Ownership' do
      it 'should show the code ownership state of file' do
        _(%w[A B C]).must_include @file.ownership_level
      end
    end
  end
end
