FactoryGirl.define do
  factory :person do
    office
    name    { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    email   { "#{name.downcase.gsub(/\s/, '.')}@neo.com" }
    notes   { Faker::HipsterIpsum.sentence }
    github  { "http://github.com/neo" }
    twitter { "https://twitter.com/neo_innovation" }
    title   { Faker::HipsterIpsum.sentence }
    bio     { Faker::HipsterIpsum.sentence }
    role    "Developer"
    percent_billable { 100 }
  end

  trait :current do
    start_date { 1.year.ago }
    end_date   { 1.year.from_now }
  end

  trait :unsellable do
    percent_billable 0
  end

  trait :past do
    start_date { 2.years.ago }
    end_date   { 1.year.ago }
  end

end
