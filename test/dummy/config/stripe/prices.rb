Stripe.price :gold do |price|
   price.name = 'Solid Gold'
   price.unit_amount = 699
   price.interval = 'month'
end

Stripe.price "Solid Gold".to_sym do |price|
   price.constant_name = 'SOLID_GOLD'
   price.name = 'Solid Gold'
   price.unit_amount = 699
   price.interval = 'month'
end

Stripe.price :alternative_currency do |price|
   price.name = 'Alternative Currency'
   price.unit_amount = 699
   price.interval = 'month'
   price.currency = 'cad'
end

Stripe.price :metered do |price|
  price.name = 'Metered'
  price.unit_amount = 699
  price.interval = 'month'
  price.usage_type = 'metered'
  price.aggregate_usage = 'max'
  price.billing_scheme = 'per_unit'
end

Stripe.price :tiered do |price|
  price.name = 'Tiered'
  price.aggregate_usage = 'max'
  price.billing_scheme = 'tiered'
  # interval must be either 'day', 'week', 'month' or 'year'
  price.interval = 'month'
  price.interval_count = 1
  price.tiers = [
    {
      unit_amount: 1500,
      up_to: 10
    },
    {
      unit_amount: 1000,
      up_to: 'inf'
    }
  ]
  price.tiers_mode = 'graduated'
  price.usage_type = 'metered'
end
