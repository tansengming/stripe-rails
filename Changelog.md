## 0.1.0 (2012-11-14)

* add config/stripe/plans.rb to define and create plans
* use `STRIPE_API_KEY` as default value of `config.stripe.api_key`
* require stripe.js from asset pipeline
* autoconfigure stripe.js with config.stripe.publishable_key.
* add rake stripe:verify to ensure stripe.com authentication is configured properly

## 0.0.1 (2012-10-12)

* basic railtie