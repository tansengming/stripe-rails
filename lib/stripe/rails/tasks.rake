namespace :stripe do
  desc 'verify your stripe.com authentication configuration'
  task 'verify' => :environment do
    begin
      Stripe::Plan.list
      puts "[OK] - connection to stripe.com is functioning properly"
    rescue Stripe::AuthenticationError => e
      puts "[FAIL] - authentication failed"
    end
  end

  task 'products:prepare' => 'environment' do
    if CurrentApiVersion.after_switch_to_products_in_plans?
      Stripe::Products.put!
    else
      puts '[SKIPPED] Current API version does not support Products'
    end
  end

  task 'plans:prepare' => 'environment' do
    Stripe::Plans.put!
  end

  task 'coupons:prepare' => 'environment' do
    Stripe::Coupons.put!
  end

  desc 'delete and redefine all coupons defined in config/stripe/coupons.rb'
  task 'coupons:reset!' => 'environment' do
    Stripe::Coupons.reset!
  end

  task 'prices:prepare' => 'environment' do
    Stripe::Prices.put!
  end

  desc 'delete and redefine all prices defined in config/stripe/prices.rb'
  task 'prices:reset!' => 'environment' do
    Stripe::Prices.reset!
  end

  desc "create all plans and coupons defined in config/stripe/{products|plans|prices|coupons}.rb"
  task 'prepare' => ['products:prepare', 'plans:prepare', 'prices:prepare', 'coupons:prepare']
end
