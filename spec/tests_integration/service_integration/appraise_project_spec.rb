# frozen_string_literal: true

require_relative '../../helpers/spec_helper.rb'
require_relative '../../helpers/vcr_helper.rb'
require_relative '../../helpers/database_helper.rb'

require 'ostruct'

describe 'AppraiseProject Service Integration Test' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_github(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Appraise a Project' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should give contributions for a folder of an existing project' do
      # GIVEN: a valid project that exists locally
      gh_project = CodePraise::Github::ProjectMapper
        .new(GITHUB_TOKEN)
        .find(USERNAME, PROJECT_NAME)
      CodePraise::Repository::For.entity(gh_project).create(gh_project)
      gitrepo = CodePraise::GitRepo.new(gh_project, CodePraise::Api.config)
      gitrepo.clone_locally unless gitrepo.exists_locally?

      # WHEN: we request to appraise the project
      request = OpenStruct.new(
        owner_name: USERNAME,
        project_name: PROJECT_NAME,
        project_fullname: USERNAME + '/' + PROJECT_NAME,
        folder_name: ''
      )

      request_id = ['test', Time.now.to_f].hash

      appraisal = CodePraise::Service::AppraiseProject.new.call(
        requested: request,
        request_id: request_id,
        config: CodePraise::Api.config
      ).value!.message

      30.times do
        sleep(1)
        print '.'
      end

      appraisal = CodePraise::Service::AppraiseProject.new.call(
        requested: request,
        request_id: request_id,
        config: CodePraise::Api.config
      )

      folder = appraisal.failure.message.appraisal["folder"]

      # THEN: we should get an appraisal

      # _(folder).must_be_kind_of CodePraise::Entity::FolderContributions
      _(folder['subfolders'].count).must_equal 10
      _(folder['base_files'].count).must_equal 2

      first_file = folder['base_files'].first
      _(%w[init.rb README.md]).must_include first_file['file_path']['filename']
      _(folder['subfolders'].first['path'].size).must_be :>, 0

      total_credits = folder['subfolders'].map { |folder| folder['total_line_credits'] }.reduce(&:+) +
                      folder['base_files'].map {|file| file['total_line_credits']}.reduce(&:+)
      _(total_credits).must_equal(folder['total_line_credits'])
    end

    it 'SAD: should not give contributions for non-existent project' do
      # GIVEN: no project exists locally

      # WHEN: we request to appraise the project
      request = OpenStruct.new(
        owner_name: USERNAME,
        project_name: PROJECT_NAME,
        project_fullname: USERNAME + '/' + PROJECT_NAME,
        folder_name: ''
      )

      result = CodePraise::Service::AppraiseProject.new.call(
        requested: request,
        config: CodePraise::Api.config
      )

      # THEN: we should get failure
      _(result.failure?).must_equal true
    end
  end
end
