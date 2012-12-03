
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

  desc "create all plans defined in config/stripe/plans.rb"
  task 'prepare' => 'plans:prepare'
end