FactoryBot.define do
  factory :order_product do
    association :order
    association :product
    quantity { rand(1..5) }
    size { %w[XS S M L XL].sample }
  end
end