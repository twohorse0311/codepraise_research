# frozen_string_literal: true

require_relative '../helpers/spec_helper'
require 'mongo'

describe CodePraise::Database::AppraisalOdm do
  before do
    @collection = Mongo::Client.new(CodePraise::Api.config.MONGODB_URL)['appraisals']
    @collection.drop
    @document = { test: 'test' }
    @collection.insert_one(@document)
  end

  describe '.find' do
    it 'recieve hash as condition to find specific document in collection' do
      appraisals = CodePraise::Database::AppraisalOdm
        .find(@document)
      _(appraisals).must_be_kind_of Array
      _(appraisals[0].document.include?('test'))
        .must_equal true
    end
  end

  describe '.create' do
    it 'inert document into collection and return a corresponding object' do
      appraisal = CodePraise::Database::AppraisalOdm
        .create(test3: 'test3')
      _(appraisal.id).wont_be_nil
    end
  end

  describe '#update' do
    it 'should update document and change the instance variable document after save' do
      appraisal = CodePraise::Database::AppraisalOdm
        .new(document: @document)
      appraisal.update_attributes(test2: 'test2')
      _(appraisal.save).must_equal true
      _(appraisal.document)
        .must_equal @document.merge!(test: 'test2')
    end
  end

  describe '#insert' do
    it 'should insert the document into collection after save' do
      appraisal = CodePraise::Database::AppraisalOdm
        .new(document: {test: 'test2'})
      _(appraisal.save).must_equal true
      _(@collection.find(test: 'test2').first).wont_be_nil
    end
  end

  describe '#delete' do
    it 'should delete the document in the collection' do
      appraisal = CodePraise::Database::AppraisalOdm
        .find(@document).first
      appraisal.delete
      _(@collection.find(@document).first).must_be_nil
    end
  end
end
