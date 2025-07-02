FactoryBot.define do
  factory :order do
    sequence(:customer_email) { |n| "customer#{n}@example.com" }
    total { rand(50.0..500.0).round(2) }
    address { "#{Faker::Address.street_name} #{Faker::Address.building_number}" }
    fulfilled { false }
  end
end