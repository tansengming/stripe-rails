Stripe.plan :gold do |plan|
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
