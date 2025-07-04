FactoryBot.define do
  factory :stock do
    size { %w[XS S M L XL].sample }
    amount { rand(1..50) }
    association :product
    
    trait :out_of_stock do
      amount { 0 }
    end
    
    trait :low_stock do
      amount { rand(1..5) }
    end
    
    trait :high_stock do
      amount { rand(100..500) }
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