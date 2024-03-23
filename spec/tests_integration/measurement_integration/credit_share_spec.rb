# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper.rb'

describe 'File-Level Measurement' do
  DatabaseHelper.setup_database_cleaner
  DatabaseHelper.wipe_database

  before do
    @measurement_helper = MeasurementHelper.setup
    @folder_contributions = @measurement_helper.folder_contributions
    @file = @folder_contributions.files[59]
    @credit_share = CodePraise::Value::CreditShare.build_object(@file)
  end

  after do
    DatabaseHelper.wipe_database
  end

  describe '+' do
    it 'should sum two CreditShare' do
      file2 = @measurement_helper.test_files[0]
      credit_share2 = CodePraise::Value::CreditShare.build_object(file2)
      total_credit_share = @credit_share + credit_share2

      _(total_credit_share.quality_credit.complexity_credits.values.sum)
        .must_equal (@credit_share.quality_credit.complexity_credits.values +
                     credit_share2.quality_credit.complexity_credits.values).sum
      _(total_credit_share.quality_credit.test_credits.values.sum)
        .must_equal credit_share2.quality_credit.test_credits.values.sum
      _(total_credit_share.productivity_credit.line_credits.values.sum)
        .must_equal (@credit_share.productivity_credit.line_credits.values +
                     credit_share2.productivity_credit.line_credits.values).sum
    end

    it 'should sum all credit in a folder' do
      total_credit_share = @folder_contributions.credit_share
      total_complexity_credits = @folder_contributions.files.map do |file|
        file.credit_share.quality_credit.complexity_credits.values
      end.flatten.sum
      total_line_credits = @folder_contributions.files.map do |file|
        file.credit_share.productivity_credit.line_credits.values
      end.flatten.sum
      _(total_credit_share.quality_credit.complexity_credits.values.sum)
        .must_equal total_complexity_credits
      _(total_credit_share.productivity_credit.line_credits.values.sum)
        .must_equal total_line_credits
    end
  end

  describe '#ownership_credit' do
    it 'shold calculate ownership credit by folder' do
      credit_share = @folder_contributions.credit_share
      _(credit_share.ownership_credit.keys[0]).must_be_kind_of String
      _(credit_share.ownership_credit.values[0]).must_be_kind_of Integer
    end
  end
end
