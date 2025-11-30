# config/initializers/stripe.rb

Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY", "sk_test_your_test_key")
