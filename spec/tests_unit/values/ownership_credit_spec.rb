# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper'

describe CodePraise::Value::OwnershipCredit do
  DatabaseHelper.setup_database_cleaner
  DatabaseHelper.wipe_database
  before(:all) do
    @measurement_helper = MeasurementHelper.setup
    # @folder = @measurement_helper.folder_contributions
    # @ownership_credits = CodePraise::Value::OwnershipCredit.new(@folder).ownership_credits
  end

  after do
    DatabaseHelper.wipe_database
  end

end
