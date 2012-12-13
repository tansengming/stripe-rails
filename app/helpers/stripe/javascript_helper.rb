module Stripe
  module JavascriptHelper
    def stripe_javascript_tag
      render :partial => 'stripe/js'
    end
  end
end