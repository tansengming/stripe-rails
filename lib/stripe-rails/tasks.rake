
namespace :stripe do
  task 'plans:prepare' => :environment do
    Stripe::Plans.put!
  end

  desc "create all plans defined in config/stripe/plans.rb"
  task 'prepare' => 'plans:prepare'
end