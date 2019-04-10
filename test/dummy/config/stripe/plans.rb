Stripe.plan :gold do |plan|
   plan.name = 'Solid Gold'
   plan.amount = 699
   plan.interval = 'month'
end

Stripe.plan "Solid Gold".to_sym do |plan|
   plan.constant_name = 'SOLID_GOLD'
   plan.name = 'Solid Gold'
   plan.amount = 699
   plan.interval = 'month'
end

Stripe.plan :alternative_currency do |plan|
   plan.name = 'Alternative Currency'
   plan.amount = 699
   plan.interval = 'month'
   plan.currency = 'cad'
end

Stripe.plan :metered do |plan|
  plan.name = 'Metered'
  plan.amount = 699
  plan.interval = 'month'
  plan.usage_type = 'metered'
  plan.aggregate_usage = 'max'
  plan.billing_scheme = 'per_unit'
end
