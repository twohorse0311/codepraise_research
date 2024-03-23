# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper.rb'

describe 'Contributor-Level Measurement' do
  DatabaseHelper.setup_database_cleaner

  before(:all) do
    @measurement_helper = MeasurementHelper.setup
    @folder_contributions = @measurement_helper.folder_contributions
    @file = @measurement_helper.file
    @file_credit_share = @file.credit_share
    @folder_credit_share = @folder_contributions.credit_share
  end

  after(:all) do
    DatabaseHelper.wipe_database
  end

  describe CodePraise::Value::CreditShare do
    describe '#line_credits' do
      it 'calculate line contribution' do
        _(@file_credit_share.productivity_credit.line_credits.values.sum).must_be :>=, 0
      end
    end

    describe '#line_percentage' do
      it 'calculate percentage of contribution' do
        skip # there is no methid call line_percentage for @file_credit_share
        _(@file_credit_share.line_percentage.values.sum).must_be :>=, 0
      end
    end

    describe '#quality_credits' do
      it 'calculate complexity and idiomaticity score' do
        _(@file_credit_share.quality_credit.keys.sort).must_equal %i[complexity_credits documentation_credits idiomaticity_credits test_credits].sort
        _(@file_credit_share.quality_credit[:complexity_credits].values.sum).must_be :>=, 0
        _(@file_credit_share.quality_credit[:idiomaticity_credits].values.sum).must_be :!=, 0
      end
    end

    describe '#method_credits' do
      it 'calculate contribution in method' do
        _(@file_credit_share.productivity_credit.method_credits.values.sum).must_be :>=, 0
        _(@file_credit_share.productivity_credit.method_credits.values.sum).must_equal @file.methods.count
      end
    end

    describe 'folder credit share' do
      it 'should calculate all file credit share in this folder' do
        contributor = @folder_contributions.contributors.first.username
        all_file_credits = @folder_contributions.files.reduce(0) do |sum, file|
          sum + file.credit_share.productivity_credit.line_credits.values.sum
        end
        _(@folder_credit_share.productivity_credit.line_credits.values.sum).must_equal all_file_credits
      end

      describe '#collective_ownership' do
        it 'calculate coefficient variation for each contributor' do
          skip # coefficient_variation and level are not calculated anymore
          contributor = @folder_contributions.contributors.first.username
          _(@folder_credit_share.collective_ownership[contributor].keys.sort)
            .must_equal %i[coefficient_variation level]
        end
      end
    end
  end
end
