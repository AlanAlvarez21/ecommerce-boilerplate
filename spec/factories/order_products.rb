FactoryBot.define do
  factory :order_product do
    association :order
    association :product
    quantity { rand(1..5) }
    size { %w[XS S M L XL].sample }
    unit_price { product&.price || rand(10.0..100.0).round(2) }

    trait :single_item do
      quantity { 1 }
    end

    trait :bulk_order do
      quantity { rand(10..50) }
    end

    trait :expensive_item do
      association :product, factory: [ :product, :expensive ]
      unit_price { product.price }
    end

    trait :cheap_item do
      association :product, factory: [ :product, :cheap ]
      unit_price { product.price }
    end

    trait :xs do
      size { "XS" }
    end

    trait :small do
      size { "S" }
    end

    trait :medium do
      size { "M" }
    end

    trait :large do
      size { "L" }
    end

    trait :xl do
      size { "XL" }
    end
  end
end
