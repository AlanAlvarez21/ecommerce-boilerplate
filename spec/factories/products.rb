FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:description) { |n| "Description for product #{n}" }
    price { rand(10.0..100.0).round(2) }
    association :category
    
    trait :expensive do
      price { rand(500.0..2000.0).round(2) }
    end
    
    trait :cheap do
      price { rand(1.0..20.0).round(2) }
    end
    
    trait :with_stock do
      after(:create) do |product|
        create(:stock, product: product, quantity: rand(10..100))
      end
    end
    
    trait :out_of_stock do
      after(:create) do |product|
        create(:stock, product: product, quantity: 0)
      end
    end
    
    trait :low_stock do
      after(:create) do |product|
        create(:stock, product: product, quantity: rand(1..5))
      end
    end
    
    trait :with_image do
      after(:build) do |product|
        product.image.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
          filename: 'test_image.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
    
    trait :featured do
      name { "Featured Product" }
      description { "This is a featured product with detailed description" }
      price { rand(100.0..300.0).round(2) }
    end
    
    trait :electronics do
      association :category, factory: [:category, :electronics]
    end
    
    trait :clothing do
      association :category, factory: [:category, :clothing]
    end
  end
end