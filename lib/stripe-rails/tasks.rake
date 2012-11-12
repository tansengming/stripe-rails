
namespace :stripe do
  desc "create all plans defined in config/stripe/plans.rb"
  task 'plans:prepare' do
    Stripe::Plans.each do |plan|
      plan.put!
    end
  end

  task 'prepare' => ['plans:prepare', 'coupons:prepare']
end