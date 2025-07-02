FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    sequence(:description) { |n| "Description for category #{n}" }
  end
end