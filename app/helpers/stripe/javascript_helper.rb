module Stripe
  module JavascriptHelper
    def stripe_javascript_tag(stripe_js_version = 'v3')
      stripe_js_version = stripe_js_version.to_s.downcase

      render 'stripe/js', stripe_js_version: stripe_js_version
    end
  end
end