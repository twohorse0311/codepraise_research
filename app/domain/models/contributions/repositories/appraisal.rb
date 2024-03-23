# frozen_string_literal: true

require 'base64'

module CodePraise
  module Repository
    class Appraisal
      def self.find_by(data)
        appraisal_odm = Database::AppraisalOdm.find(data).first

        return appraisal_odm unless appraisal_odm

        build_entity(appraisal_odm)
      end

      def self.find_id(id)
        appraisal_odm = Database::AppraisalOdm.find(_id: BSON::ObjectId(id)).first

        return appraisal_odm unless appraisal_odm

        build_entity(appraisal_odm)
      end

      def self.find_or_create_by(data)
        appraisal = find_by(project_name: data[:project_name],
                            owner_name: data[:owner_name])

        return appraisal if appraisal

        data[:created_at] = Time.now
        data[:updated_at] = Time.now
        data[:state] = 'init'
        appraisal = Database::AppraisalOdm.create(data)
        build_entity(appraisal)
      end

      def self.update(id:, data:)
        appraisal_odm = Database::AppraisalOdm.find(_id: BSON::ObjectId(id)).first

        return appraisal_odm unless appraisal_odm

        data[:updated_at] = Time.now
        appraisal_odm.update_attributes(data)
        return nil unless appraisal_odm.save

        find_id(appraisal_odm.id)
      end

      def self.delete(data)
        appraisal_odm = Database::AppraisalOdm.find(data).first
        appraisal_odm.delete
      end

      def self.build_entity(odm)
        return nil unless odm

        Entity::Appraisal.new(
          id: odm.id,
          project_name: odm.document['project_name'],
          owner_name: odm.document['owner_name'],
          appraisal: odm.document['appraisal'],
          state: odm.document['state'],
          request_id: odm.document['request_id'],
          created_at: odm.document['created_at'].localtime('+08:00'),
          updated_at: odm.document['updated_at'].localtime('+08:00')
        )
      end
    end
  end
end
