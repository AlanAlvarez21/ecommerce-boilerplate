FactoryBot.define do
  factory :order do
    sequence(:customer_email) { |n| "customer#{n}@example.com" }
    total { rand(50.0..500.0).round(2) }
    address { "#{Faker::Address.street_name} #{Faker::Address.building_number}" }
    status { :pending }
    payment_id { "MP-#{SecureRandom.hex(10)}" }
    
    trait :pending do
      status { :pending }
    end
    
    trait :processing do
      status { :processing }
    end
    
    trait :delivered do
      status { :delivered }
    end
    
    trait :cancelled do
      status { :cancelled }
    end
    
    trait :today do
      created_at { Time.current }
    end
    
    trait :yesterday do
      created_at { 1.day.ago }
    end
    
    trait :this_week do
      created_at { rand(1.week.ago..Time.current) }
    end
    
    trait :with_products do
      after(:create) do |order|
        create_list(:order_product, 3, order: order)
      end
    end
    
    trait :high_value do
      total { rand(1000.0..5000.0).round(2) }
    end
    
    trait :low_value do
      total { rand(10.0..50.0).round(2) }
    end
    
    # Legacy support for existing tests
    trait :fulfilled do
      status { :delivered }
    end
    
    # Keep this for backwards compatibility
    fulfilled { status == 'delivered' }
  end
end