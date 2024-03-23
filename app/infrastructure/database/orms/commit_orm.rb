require 'sequel'

module CodePraise
  module Database
    # Object Relational Mapper for Project Entities
    class CommitOrm < Sequel::Model(:commits)
      many_to_one :project,
                  class: :'CodePraise::Database::ProjectOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
