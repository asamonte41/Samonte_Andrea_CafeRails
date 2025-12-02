require "faker"

namespace :import do
  desc "Generate fake API-style product data using Faker"
  task fake_products: :environment do
    puts "Creating categories first..."

    categories = [
      "Coffee",
      "Tea",
      "Pastries",
      "Sandwiches",
      "Snacks"
    ]

    category_records = categories.map do |name|
      Category.find_or_create_by!(name: name) do |cat|
        cat.description = Faker::Lorem.sentence(word_count: 8)
      end
    end

    puts "Categories ready: #{category_records.map(&:name).join(', ')}"
    puts "Generating fake products..."

    20.times do
      Product.create!(
        name: Faker::Commerce.product_name,
        description: Faker::Lorem.paragraph(sentence_count: 4),
        price: Faker::Commerce.price(range: 3.0..25.0),
        stock: Faker::Number.between(from: 5, to: 40),
        on_sale: Faker::Boolean.boolean(true_ratio: 0.3),
        new_arrival: Faker::Boolean.boolean(true_ratio: 0.3),
        recently_updated: Faker::Boolean.boolean(true_ratio: 0.3),
        category: category_records.sample
      )
    end

    puts "Created 20 fake API-style products!"
  end
end
