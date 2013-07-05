FactoryGirl.define do
  factory :person do
    office
    name   { Faker::Name.name }
    email  { Faker::Internet.email }
    notes  { Faker::HipsterIpsum.sentence }
  end
end
