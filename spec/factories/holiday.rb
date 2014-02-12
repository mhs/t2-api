FactoryGirl.define do
  factory :holiday do
    name "Festivus"
    start_date { 6.months.from_now }
    end_date { 6.months.from_now }
  end
end
