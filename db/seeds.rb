require 'csv'

puts "Clearing existing data..."
Product.destroy_all
Category.destroy_all
Province.destroy_all
Page.destroy_all

puts "Seeding categories and products from CSV..."

# ---------------------------
# Pages (About / Contact)
# ---------------------------
Page.find_or_create_by!(slug: "about") do |p|
  p.title = "About Us"
  p.content = "Welcome to our website! Here’s some information about us."
end

Page.find_or_create_by!(slug: "contact") do |p|
  p.title = "Contact Us"
  p.content = "You can contact us via email at contact@example.com."
end

# ---------------------------
# Provinces
# ---------------------------
Province.create!([
  { name: "Alberta", abbreviation: "AB", gst_cents: 5, pst_cents: 0, hst_cents: 0 },
  { name: "British Columbia", abbreviation: "BC", gst_cents: 5, pst_cents: 7, hst_cents: 0 },
  { name: "Manitoba", abbreviation: "MB", gst_cents: 5, pst_cents: 7, hst_cents: 0 },
  { name: "New Brunswick", abbreviation: "NB", gst_cents: 0, pst_cents: 0, hst_cents: 15 },
  { name: "Newfoundland and Labrador", abbreviation: "NL", gst_cents: 0, pst_cents: 0, hst_cents: 15 },
  { name: "Nova Scotia", abbreviation: "NS", gst_cents: 0, pst_cents: 0, hst_cents: 15 },
  { name: "Ontario", abbreviation: "ON", gst_cents: 0, pst_cents: 0, hst_cents: 13 },
  { name: "Prince Edward Island", abbreviation: "PE", gst_cents: 0, pst_cents: 0, hst_cents: 15 },
  { name: "Quebec", abbreviation: "QC", gst_cents: 5, pst_cents: 9.975, hst_cents: 0 },
  { name: "Saskatchewan", abbreviation: "SK", gst_cents: 5, pst_cents: 6, hst_cents: 0 },
  { name: "Northwest Territories", abbreviation: "NT", gst_cents: 5, pst_cents: 0, hst_cents: 0 },
  { name: "Nunavut", abbreviation: "NU", gst_cents: 5, pst_cents: 0, hst_cents: 0 },
  { name: "Yukon", abbreviation: "YT", gst_cents: 5, pst_cents: 0, hst_cents: 0 }
])

# ---------------------------
# Categories & Products
# ---------------------------
csv_file_path = Rails.root.join('db', 'data', 'products.csv')
image_path = Rails.root.join('db', 'data/images')
placeholder_file = image_path.join('placeholder.png') # fallback if image missing

CSV.foreach(csv_file_path, headers: true) do |row|
  next if row['name'].blank? || row['category_name'].blank?

  # Create category
  category = Category.find_or_create_by!(name: row['category_name']) do |c|
    c.description = case row['category_name']
    when "Baked Goods"
      "Fresh pastries, macarons, cookies, brownies, cupcakes and artisan tarts baked daily by our talented pastry chefs."
    when "Beverages"
      "Premium specialty coffee blends, artisan teas, rich hot chocolate, and bubble tea kits for the perfect drink at home."
    when "Dessert Kits"
      "Create your own delicious treats at home with our easy-to-follow DIY macaron kits, cake decorating kits, and boba tea starter packs."
    when "Gift Boxes"
      "Beautifully curated assortments of our finest treats, perfect for birthdays, holidays, and special occasions."
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

  # Attach image: use product image or placeholder
  image_file = if row['image_filename'].present? && File.exist?(image_path.join(row['image_filename']))
                 image_path.join(row['image_filename'])
  else
                 placeholder_file
  end

  product.image.attach(
    io: File.open(image_file),
    filename: row['image_filename'].present? ? row['image_filename'] : 'placeholder.png'
  )
end

puts "Seeding complete!"
puts "Summary:"
puts "- Provinces: #{Province.count}"
puts "- Categories: #{Category.count}"
puts "- Products: #{Product.count}"
