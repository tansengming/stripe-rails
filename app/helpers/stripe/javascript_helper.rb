module Stripe
  module JavascriptHelper
    DEFAULT_STRIPE_JS_VERSION = 'v3'

    def stripe_javascript_tag(stripe_js_version = DEFAULT_STRIPE_JS_VERSION)
      stripe_js_version = stripe_js_version.to_s.downcase

      render 'stripe/js', stripe_js_version: stripe_js_version
    end

    def stripe_elements_tag(stripe_public_key: ENV["STRIPE_PUBLIC_KEY"], submit_path:, options: {})
      default_options = {
        label_text: "Credit or debit card",
        submit_button_text: "Submit payment",
        default_css: true,
        default_js: true
      }

      render partial: 'stripe/elements', locals: {
        stripe_public_key: stripe_public_key,
        submit_path: submit_path,
        options: default_options.merge(options).with_indifferent_access
      }
    end
  end
end
