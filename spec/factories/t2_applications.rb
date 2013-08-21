# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :t2_application, :class => 'T2Applications' do
    url "http://example.com"
    icon "f"
    title "Allocations"
    position 1
  end
end
