FactoryGirl.define do
  factory :opportunity do
    title { Faker::Lorem.words(1) }
    stage 'new'
    confidence 'warm'
    amount 1000
    expected_date_close (Time.now + 10.days)
    company
    person
  end
end
