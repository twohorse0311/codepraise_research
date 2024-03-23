# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper'

describe CodePraise::Value::ProductivityCredit do
  DatabaseHelper.setup_database_cleaner
  DatabaseHelper.wipe_database

  before(:all) do
    @measurement_helper = MeasurementHelper.setup
    @file = @measurement_helper.file
    @productivity_credit = CodePraise::Value::ProductivityCredit
      .build_object(@file.lines, @file.methods)
  end

  after do
    DatabaseHelper.wipe_database
  end
end
