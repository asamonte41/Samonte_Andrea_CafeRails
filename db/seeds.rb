require 'csv'

puts "Clearing existing data..."
Product.destroy_all
Category.destroy_all

puts "Seeding categories and products from CSV..."

csv_file_path = Rails.root.join('db', 'data', 'products.csv')
image_path = Rails.root.join('db', 'data', 'images')

CSV.foreach(csv_file_path, headers: true) do |row|
  # Create or find category
  category = Category.find_or_create_by!(name: row['category_name']) do |c|
    c.description = case row['category_name']
    when "Baked Goods"
      "Fresh pastries, macarons, cookies, brownies, cupcakes and artisan tarts baked daily by our talented pastry chefs."
    when "Beverages"
      "Premium specialty coffee blends, artisan teas, rich hot chocolate, and bubble tea kits for the perfect drink at home."
    when "Dessert Kits"
      "Create your own delicious treats at home with our easy-to-follow DIY macaron kits, cake decorating kits, and boba tea starter packs."
    when "Gift Boxes"
      "Beautifully curated assortments of our finest treats, perfect for birthdays, anniversaries, holidays, and special occasions."
    when "Seasonal Specials"
      "Limited edition desserts and beverages themed for holidays or seasonal events."
    else
      "Products for Cafe Rails"
    end
  end

  # Create product
  product = Product.create!(
    name: row['name'],
    description: row['description'],
    price: row['price'].to_f,
    stock: row['stock'].to_i,
    category: category
  )

  # Attach image if present
  if row['image_filename'] && File.exist?(image_path.join(row['image_filename']))
    product.image.attach(
      io: File.open(image_path.join(row['image_filename'])),
      filename: row['image_filename']
    )
  end
end

puts "Seeding complete!"
puts "Summary:"
puts "- Categories: #{Category.count}"
puts "- Products: #{Product.count}"
