module Stripe
  module JavascriptHelper
    DEFAULT_STRIPE_JS_VERSION = 'v3'

    def stripe_javascript_tag(stripe_js_version = DEFAULT_STRIPE_JS_VERSION)
      stripe_js_version = stripe_js_version.to_s.downcase

      render 'stripe/js', stripe_js_version: stripe_js_version
    end

    def stripe_elements_tag(submit_path:,
                            css_path: asset_path("stripe_elements.css"),
                            js_path: asset_path("stripe_elements.js"))

      render partial: 'stripe/elements', locals: {
        submit_path: submit_path,
        label_text: t('stripe_rails.elements.label_text'),
        submit_button_text: t('stripe_rails.elements.submit_button_text'),
        css_path: css_path,
        js_path: js_path
      }
    end
  end
end
