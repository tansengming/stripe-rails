# This file contains descriptions of all your stripe products

# Example
# Stripe::Products::PRIMO #=> 'primo'

# Stripe.products :primo do |products|
#   # products name as it will appear on credit card statements
#   products.name = 'Acme as a service PRIMO'
#
#   # Product, either 'service' or 'good'
#   products.type = 'service'
# end

# Once you have your productss defined, you can run
#
#   rake stripe:prepare
#
# This will export any new plans to stripe.com so that you can
# begin using them in your API calls.
