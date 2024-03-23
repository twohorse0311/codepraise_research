# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:commits) do
      primary_key :id
      foreign_key :project_id, :projects

      String      :sha, unique: true
      Integer      :commit_date

      DateTime :created_at
      DateTime :updated_at
    end
  end
end