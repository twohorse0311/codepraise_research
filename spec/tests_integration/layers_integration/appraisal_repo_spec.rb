# frozen_string_literal: true

require_relative '../../helpers/spec_helper.rb'
require_relative '../../helpers/database_helper.rb'

describe CodePraise::Repository::Appraisal do
  DatabaseHelper.setup_database_cleaner
  DatabaseHelper.wipe_database

  before do
    @appraisal_repo = CodePraise::Repository::Appraisal
    @data = {
      project_name: 'test',
      owner_name: 'test',
      appraisal: { test: 'test' },
      request_id: 'test',
      state: 'init'
    }
  end

  after do
    DatabaseHelper.wipe_database
  end

  describe '#find_or_create_by' do
    it 'create an appraisal and return appraisal entity' do
      appraisal = @appraisal_repo.find_or_create_by(@data)
      _(appraisal).must_be_instance_of CodePraise::Entity::Appraisal
      _(appraisal.id).wont_be_nil
      _(appraisal.project_name).must_equal @data[:project_name]
    end
    it 'create init appraisal without appraisal info' do
      @data.delete(:appraisal)
      appraisal = @appraisal_repo.find_or_create_by(@data)
      _(appraisal).must_be_instance_of CodePraise::Entity::Appraisal
      _(appraisal.id).wont_be_nil
      _(appraisal.project_name).must_equal @data[:project_name]
    end
  end

  describe '#update' do
    it 'update appraisal data and return appraisal entity' do
      appraisal = @appraisal_repo.find_or_create_by(@data)
      updated_appraisal = @appraisal_repo.update(id: appraisal.id,
                                                 data: { state: 'test' })
      _(updated_appraisal.id).must_equal appraisal.id
      _(updated_appraisal.state).must_equal 'test'
    end
  end

  describe '#find_by' do
    it 'find appraisal by project name and owner name' do
      appraisal = @appraisal_repo.find_or_create_by(@data)
      finded_appraisal = @appraisal_repo.find_by(project_name: @data[:project_name],
                                                 owner_name: @data[:owner_name])
      _(finded_appraisal.id).must_equal appraisal.id
    end
  end
end
