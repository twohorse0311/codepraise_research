# frozen_string_literal: true

require 'mongo'

module CodePraise
  module Database
    # Appraisal Cache Object to connect MongoDB
    class AppraisalOdm
      COLLECTION = CodePraise::Api.mongo['appraisals']

      attr_reader :document, :id

      def initialize(document:, id: nil)
        @document = document
        @new_document = document
        @id = id
      end

      def update_attributes(new_attributes)
        @new_document = @document.merge(new_attributes)
      end

      def update
        result = COLLECTION.update_one(@document, '$set': @new_document)
        result.n == 1
      end

      def insert
        result = COLLECTION.insert_one(@new_document)
        result.n == 1
      end

      def save
        if new_record?
          update
        else
          insert
        end
      end

      def self.all
        COLLECTION.find.map do |doc|
          build_object(doc)
        end
      end
      

      def delete
        COLLECTION.delete_one(@document)
      end

      def new_record?
        !id.nil?
      end

      def self.build_object(document)
        new(
          document: document,
          id: document['_id']&.to_s
        )
      end

      def self.find(document)
        return [] if COLLECTION.find(document).first.nil?

        COLLECTION.find(document).map do |doc|
          build_object(doc)
        end
      end

      def self.create(document)
        result = COLLECTION.insert_one(document)

        return nil if result.n != 1

        find(document).first
      end
    end
  end
end
