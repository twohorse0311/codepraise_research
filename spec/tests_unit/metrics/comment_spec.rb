# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/measurement_helper'
require_relative '../../helpers/database_helper'

describe CodePraise::Entity::Complexity do
  DatabaseHelper.setup_database_cleaner

  before do
    @measurement_helper = MeasurementHelper.setup

    @comments = CodePraise::Mapper::Comments
      .new(@measurement_helper.folder_contributions.files[0].lines)
      .build_entities
  end

  after do
    DatabaseHelper.wipe_database
  end

  describe '#lines' do
    it 'collect lines of comment' do
      _(@comments[0].lines[0]).must_be_kind_of CodePraise::Entity::LineContribution
    end
  end

  describe '#type' do
    it { _(%w[multi-line single-line]).must_include @comments[0].type }
  end

  describe '#is_documentation' do
    it { _([true, false]).must_include @comments[0].is_documentation }
  end


  # There is no "line_credits" method in comment entity
  describe '#line_credits' do 
    it 'show the contribution information of comment' do
      skip
      _(@measurement_helper.contributors)
        .must_include @comments[0].line_credits.keys[0]
      _(@comments[0].line_credits.values.reduce(&:+))
        .must_equal @comments[0].lines.size
    end
  end
end
