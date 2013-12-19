FactoryGirl.define do
  factory :opportunity_note do
    detail { Faker::Lorem.sentence(10) }
    opportunity
    person
  end
end
