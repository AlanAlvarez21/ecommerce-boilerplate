FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:description) { |n| "Description for product #{n}" }
    price { rand(10.0..100.0).round(2) }
    association :category
  end
end