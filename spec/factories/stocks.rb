FactoryBot.define do
  factory :stock do
    size { %w[XS S M L XL].sample }
    amount { rand(1..50) }
    association :product
  end
end