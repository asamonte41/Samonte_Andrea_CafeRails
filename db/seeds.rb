# Clear existing data
puts "Clearing existing data..."
Product.destroy_all
Category.destroy_all

puts "Creating categories..."

# Create Categories (Req 1.5)
baked_goods = Category.create!(
  name: "Baked Goods",
  description: "Fresh pastries, macarons, cookies, brownies, cupcakes and artisan tarts baked daily by our talented pastry chefs."
)

beverages = Category.create!(
  name: "Beverages",
  description: "Premium specialty coffee blends, artisan teas, rich hot chocolate, and bubble tea kits for the perfect drink at home."
)

dessert_kits = Category.create!(
  name: "DIY Dessert Kits",
  description: "Create your own delicious treats at home with our easy-to-follow DIY macaron kits, cake decorating kits, and boba tea starter packs."
)

gift_boxes = Category.create!(
  name: "Gift Boxes",
  description: "Beautifully curated assortments of our finest treats, perfect for birthdays, anniversaries, holidays, and special occasions."
)

puts "Created #{Category.count} categories"
puts "Creating products..."

# Create Products (Minimum 10 required) (Req 1.2 ✯, 1.6)

# Baked Goods Category
Product.create!([
  {
    name: "French Macarons Box (12 pieces)",
    description: "Delicate almond meringue cookies with smooth buttercream filling. Assorted flavors include vanilla, chocolate, raspberry, pistachio, lemon, and salted caramel. Each macaron is handcrafted with precision for the perfect texture and taste.",
    price: 24.99,
    stock: 50,
    category: baked_goods,
    on_sale: false,
    new_arrival: true
  },
  {
    name: "Artisan Chocolate Brownies (6 pack)",
    description: "Rich, fudgy brownies made with premium Belgian chocolate. Dense and moist with a crackly top, these brownies are a chocolate lover's dream. Perfect with a glass of milk or a cup of coffee.",
    price: 18.99,
    stock: 75,
    category: baked_goods,
    on_sale: true,
    new_arrival: false
  },
  {
    name: "Assorted Cookies Box (24 pieces)",
    description: "A delightful variety of our most popular cookies including chocolate chip, oatmeal raisin, snickerdoodle, and double chocolate. Baked fresh daily and perfect for sharing or enjoying throughout the week.",
    price: 22.99,
    stock: 60,
    category: baked_goods,
    on_sale: false,
    new_arrival: false
  },
  {
    name: "Cream Puff Tower (8 pieces)",
    description: "Light and airy choux pastry filled with vanilla custard cream and topped with a delicate chocolate glaze. An elegant dessert that's perfect for special occasions or as an everyday indulgence.",
    price: 28.99,
    stock: 30,
    category: baked_goods,
    on_sale: false,
    new_arrival: true
  }
])

# Beverages Category
Product.create!([
  {
    name: "Specialty Coffee Blend (250g)",
    description: "Premium single-origin Arabica coffee beans sourced from Colombia. Medium roast with notes of chocolate, caramel, and hazelnut. Ground or whole bean options available. Makes approximately 25 cups.",
    price: 16.99,
    stock: 100,
    category: beverages,
    on_sale: true,
    new_arrival: false
  },
  {
    name: "Artisan Tea Collection (20 sachets)",
    description: "Curated selection of premium loose leaf teas including Earl Grey, English Breakfast, Green Tea, Chamomile, and Peppermint. Each sachet is biodegradable and perfectly portioned for a flavorful cup.",
    price: 19.99,
    stock: 85,
    category: beverages,
    on_sale: false,
    new_arrival: false
  },
  {
    name: "Bubble Tea Kit - Classic Milk Tea",
    description: "Everything you need to make authentic bubble tea at home. Includes premium black tea, tapioca pearls, brown sugar syrup, and reusable straws. Makes 8-10 servings. Easy step-by-step instructions included.",
    price: 32.99,
    stock: 45,
    category: beverages,
    on_sale: false,
    new_arrival: true
  }
])

# DIY Kits Category
Product.create!([
  {
    name: "DIY Macaron Baking Kit",
    description: "Create your own French macarons at home with this complete kit. Includes pre-measured almond flour, powdered sugar, food coloring, piping bags, templates, and detailed video tutorial. Makes 24 macarons.",
    price: 38.99,
    stock: 40,
    category: dessert_kits,
    on_sale: false,
    new_arrival: true
  },
  {
    name: "Cake Decorating Starter Kit",
    description: "Perfect for beginners! Kit includes piping bags, decorating tips, spatulas, turntable, and our signature buttercream recipe. Transform any cake into a masterpiece with professional tools and guidance.",
    price: 44.99,
    stock: 35,
    category: dessert_kits,
    on_sale: true,
    new_arrival: false
  }
])

# Gift Boxes Category
Product.create!([
  {
    name: "Deluxe Dessert Gift Box",
    description: "An elegant gift box featuring 6 macarons, 4 cream puffs, 6 assorted cookies, and 2 brownies. Beautifully packaged with ribbon and a personalized gift card. Perfect for birthdays, thank you gifts, or celebrations.",
    price: 54.99,
    stock: 25,
    category: gift_boxes,
    on_sale: false,
    new_arrival: true
  }
])

puts "Created #{Product.count} products"
puts "Seeding complete!"
puts ""
puts "Summary:"
puts "- Categories: #{Category.count}"
puts "- Products: #{Product.count}"
puts "- Products on sale: #{Product.where(on_sale: true).count}"
puts "- New arrivals: #{Product.where(new_arrival: true).count}"
