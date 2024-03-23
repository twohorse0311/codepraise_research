require_relative 'member_factory'

FactoryBot.define do
  factory :project, class: 'CodePraise::Database::ProjectOrm' do
    origin_id { 184028231 }
    name {'codepraise-api'}
    size { 551 }
    ssh_url { 'git://github.com/XuVic/YPBT-app.git' }
    http_url { 'https://github.com/soumyaray/YPBT-app' }
    # http_url { 'https://github.com/ISS-SOA/codepraise-api' }
    association :owner, factory: :member
    initialize_with { CodePraise::Database::ProjectOrm.find(origin_id: 184028231) || CodePraise::Database::ProjectOrm.create(attributes) }
  end
end