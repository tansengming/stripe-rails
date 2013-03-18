
namespace :stripe do

  desc 'verify your stripe.com authentication configuration'
  task 'verify' => :environment do
    begin
      Stripe::Plan.all
      puts "[OK] - connection to stripe.com is functioning properly"
    rescue Stripe::AuthenticationError => e
      puts "[FAIL] - authentication failed"
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

  desc "create all plans and coupons defined in config/stripe/{plans|coupons}.rb"
  task 'prepare' => ['plans:prepare', 'coupons:prepare']
end