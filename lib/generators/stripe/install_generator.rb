module Stripe
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../../templates", __FILE__)

    desc "copy plans.rb into place"
    def copy_plans_file
      copy_file "plans.rb", "config/plans.rb"
    end
  end
end