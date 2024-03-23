FactoryBot.define do
  factory :member, class: 'CodePraise::Database::MemberOrm' do
    origin_id { 11512564 }
    username { 'ISS-SOA' }
    email { 'xumingyo@gmail.com' }
    initialize_with { CodePraise::Database::MemberOrm.find(origin_id: origin_id) || CodePraise::Database::MemberOrm.create(attributes) }
  end
end