module Stripe
  class InstallGenerator < ::Rails::Generators::Base
    source_root ::File.expand_path("../../templates", __FILE__)

    desc "copy plans.rb"
    def copy_plans_file
      copy_file "products.rb", "config/stripe/products.rb"
      copy_file "plans.rb", "config/stripe/plans.rb"
      copy_file "prices.rb", "config/stripe/prices.rb"
      copy_file "coupons.rb", "config/stripe/coupons.rb"
    end
  end
end