FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    sequence(:description) { |n| "Description for category #{n}" }

    trait :electronics do
      name { "Electronics" }
      description { "Electronic devices and accessories" }
    end

    trait :clothing do
      name { "Clothing" }
      description { "Apparel and fashion items" }
    end

    trait :books do
      name { "Books" }
      description { "Literature and educational materials" }
    end

    trait :with_image do
      after(:build) do |category|
        category.image.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
          filename: 'category_image.jpg',
          content_type: 'image/jpeg'
        )
      end
    end

    trait :with_products do
      after(:create) do |category|
        create_list(:product, 5, category: category)
      end
    end
  end
end
