module Stripe
  module JavascriptHelper
    DEFAULT_STRIPE_JS_VERSION = 'v3'

    def stripe_javascript_tag(stripe_js_version = DEFAULT_STRIPE_JS_VERSION)
      stripe_js_version = stripe_js_version.to_s.downcase

      render 'stripe/js', stripe_js_version: stripe_js_version
    end

    def stripe_elements_tag
      render 'stripe/elements'
    end
  end
end
