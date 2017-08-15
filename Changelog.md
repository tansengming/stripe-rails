## 1.0.2 (2017-08-15)

* Remove authenticity token check (thanks @lewispb)
* Adding timeout options to config (thanks @rgerard)
* Add 'day' as possible plan interval (thanks @vdragsic and @artemave)

## 1.0.1 (2017-08-08)

* Fixes a bug with Stripe JS V3, i.e. `Stripe.setPublishableKey` is no longer a function. Thanks to @kartikluke for reporting this.

## 1.0.0 (2017-07-24 - Breaky McBreakface)

* [BREAKING] Update to latest stripe events (thanks @hopsoft). Note that if you are using the `after_customer_card_created`, `after_customer_card_updated` or `after_customer_card_deleted` callbacks, you MUST update them to `after_customer_source_created`, `after_customer_source_updated` or `after_customer_source_deleted` respectively. You also need to start using [Stripe API Version > 2015-02-18](https://stripe.com/docs/upgrades#2015-02-18) or else the webhook might not work as expected.
* [BREAKING] Updates to the [latest version of Stripe JS](https://github.com/Everapps/stripe-rails/pull/69). If you were using `stripe_javascript_tag` without specifying the version number, note that it will now default to Stripe JS v3. This version is incompatible with the previous default.
* The gem will only be tested on Rails 4 and 5 [from now on](https://github.com/Everapps/stripe-rails/pull/62).
* Gem will henceforth only [be tested](https://github.com/Everapps/stripe-rails/pull/68) on Ruby >= 2.1.9.
* add statement descriptor to plan attributes (thanks @jbender)
* Relax version constraint on the responders gem

## 0.4.1 (2017-06-01)

* Support for api_version header parameter (thanks @kiddrew)
* Relax version constraint on stripe gem (thanks @gaffneyc)

## 0.4.0 (2017-05-24)
* Support alternate versions of stripe js

## 0.3.2 (2017-03-06)
* add `responders` gem as dependency to support `respond_to` method
* fix unit tests with Rails 4.2 and Rails 5.0

## 0.3.1 (2014-08-07)
* add `eager_load` option to load callbacks into classes in non-eager-loaded enviroments

## 0.3.0 (2014-04-29)
* Rename api_key to secret_key

## 0.2.6 (2013-10-17)
* add `auto_mount` option to allow for manually mounting the webhook endpoints

## 0.2.5 (2013-03-18)
* make the default max redemptions 1
* add stripe::coupons::reset! task to redefine all coupons

## 0.2.2 (2013-01-09)
* bugfix allowing creation of coupons without max_redemptions

## 0.2.1 (2012-12-17)
* manage coupons with config/stripe/coupons.rb

## 0.2.0 (2012-12-13)

* out of the box support for webhooks and critical/non-critical event handlers
* add :only guards for which webhooks you respond to-
* move stripe.js out of asset pipeline, and insert it with utility functions

## 0.1.0 (2012-11-14)

* add config/stripe/plans.rb to define and create plans
* use `STRIPE_API_KEY` as default value of `config.stripe.api_key`
* require stripe.js from asset pipeline
* autoconfigure stripe.js with config.stripe.publishable_key.
* add rake stripe:verify to ensure stripe.com authentication is configured properly

## 0.0.1 (2012-10-12)

* basic railtie
