module Stripe
  module JavascriptHelper
    def stripe_javascript_tag(stripe_js_version = 'v1')
      stripe_js_version = stripe_js_version.to_s

      case stripe_js_version
      when 'v1', 'v2'
        if ::Rails.application.config.stripe.debug_js
          render 'stripe/debug_js', stripe_js_version: stripe_js_version
        else
          render 'stripe/js', stripe_js_version: stripe_js_version
        end
      when 'v3' # no debug js for v3
        render 'stripe/js', stripe_js_version: stripe_js_version
      end
    end
  end
end