FactoryGirl.define do
  factory :office do
    name  { Faker::Address.city.gsub(" ", "-") }
    notes { Faker::HipsterIpsum.sentence }
  end
end
