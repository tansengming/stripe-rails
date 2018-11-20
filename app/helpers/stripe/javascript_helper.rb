module Stripe
  module JavascriptHelper
    DEFAULT_STRIPE_JS_VERSION = 'v3'

    def stripe_javascript_tag(stripe_js_version = DEFAULT_STRIPE_JS_VERSION)
      stripe_js_version = stripe_js_version.to_s.downcase

      render 'stripe/js', stripe_js_version: stripe_js_version
    end

    def stripe_elements_tag(submit_path:, label_text: t("stripe_rails.elements.label_text"),
                            submit_button_text: t("stripe_rails.elements.submit_button_text"),
                            default_css: true,
                            default_js: true)

      render partial: 'stripe/elements', locals: {
        submit_path: submit_path,
        label_text: label_text,
        submit_button_text: submit_button_text,
        default_css: default_css,
        default_js: default_js
      }
    end
  end
end
