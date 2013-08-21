FactoryGirl.define do
  sequence(:uid) {|n| "uid#{n}"}
  factory :user do
    provider "google"
    uid
  end
end
