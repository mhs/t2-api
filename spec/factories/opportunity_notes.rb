FactoryGirl.define do
  factory :opportunity_note do
    detail { Faker::Lorem.sentence(10) }
    person
  end
end
