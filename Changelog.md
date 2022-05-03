## Unreleased

## 2.3.4 (2022-05-03)

-  Add setup_intent.canceled and setup_intent.requires_action callbacks. Thanks @jamesjason !

## 2.3.3 (2021-12-17)

-  Add checkout.session.expired callback. Thanks @danielwellman !

## 2.3.2 (2021-10-15)

-  Add Subscription Schedule and Tax Rate Callbacks #213 . Thanks @lesliepoolman !

## 2.3.1 (2021-09-17)

-  Add price callbacks. Thanks @StevenElberger !

## 2.3.0 (2021-03-08)

- Adds testing for Rails 6.0
- Add `name` attribute to coupons. Thanks @ZilvinasKucinskas!

## 2.2.1 (2020-12-22)

- Add payment_intent.requires_action callback, thanks @VadimLeader.

## 2.2.0 (2020-12-06)

- Add Prices as a configuration object. Thanks @jamesprior!

## 2.1.0 (2020-10-18)

- Added option to ignore missing API key and don't show any warning. Thanks @ndbroadbent!
- Handle passing nil to signing_secret= and add tests. Thanks @martron!

## 2.0.0 (2020-09-18)

- Everything from on the 2.0.0.pre release
- includes changes from the 1.10.2 release

## 1.10.2 (2020-09-18)

- adds missing callback `invoice.paid`. Thanks @SyborgStudios.

## 2.0.0.pre (2020-05-29)

* [Breaking] Updated to work only with Rails >= 5.1
* [Breaking] It'll only be tested on Ruby 2.7, 2.6 and 2.5.
* [Breaking] Supports the Stripe gem => 3.15.0 (from 2 years ago)
* [Breaking] Removes Stripe::PingsController controller.

## 1.10.1 (2020-05-29)

- adds missing callbacks for `payment_intent`. Thanks @klapperkopp .

## 1.10.0 (2020-03-31)

- Adds support for using multiple tiers in a plan, thanks @cpsoinos

## 1.9.1 (2019-10-28)

- Fixes issue with `rake stripe:verify` thanks @Millariel !

## 1.9.0 (2019-09-01)

- Adds support for multiple signing secrets. Thanks again @jacobcsmith !

## 1.8.2 (2019-08-31)

- adds missing callbacks for `payment_intent`, `payment_method` and `setup_intent`. Thanks @jacobcsmith !

## 1.8.1 (2019-07-26)

* adds callback for invoice.payment_action_required. Thanks @alexagranov .
* fixes when clearing callbacks after unload doesn't play nice with eager_load. Thanks @alexagranov for reporting the problem and coming up with an initial fix for it.

## 1.8.0 (2019-07-25)

* Configure publishable key from ENV. Thanks @cyu .

## 1.7.2 (2019-06-29)

* fixes `require` error after update from Stripe gem. Thanks @dark-panda !

## 1.7.1 (2019-05-24)

* Don't assume sprockets are loaded thanks @manusajith

## 1.7.0 (2019-05-09)

* [New Feature] add support for Plan to use a constant name different from plan id thanks @alexagranov !
* Add checkout.session.completed webhook thanks @Nitrino !

## 1.6.1 (2019-03-04)

* Add new invoice webhooks thanks @noahezekwugo !

## 1.6.0 (2019-01-08)

* New Year New Feature: Easily include Stripe Elements into your project thanks to @garrettqmartin8 !
* Travis is now testing the gem on Ruby 2.6.0

## 1.5.5 (2018-12-16)

* Fixed issue with Rails development and Spring: Clear callbacks before files are reloaded during development and test - thanks @ndbroadbent

## 1.5.4 (2018-11-14)

* Removes test exception from event dispatch
* Travis is now testing the gem on Ruby 2.5.3, 2.4.5, 2.3.8

## 1.5.3 (2018-10-25)

* Add usage_type, aggregate_usage, and billing_scheme - thanks @garrettqmartin8

## 1.5.2 (2018-10-15)

* fixes undefined method `expand_path' for Stripe::File:Class - Thanks to @BitesGit for reporting this.

## 1.5.1 (2018-10-01)

* Allow statement_descriptor to be set on products - Thanks to @jeanmartin


## 1.5.0 (2018-09-27)

* Add Webhook Signature Validation - Thanks to @wkirby
* Include nickname in the payload for plans - Thanks to @jeanmartin

## 1.4.2 (2018-08-06)

* New attributes for Stripe Billing Plans.

## 1.4.1 (2018-08-03)

* Fixes ActionController::UnknownFormat errors - Thanks to @ndbroadbent !

## 1.4.0 (2018-07-30)

* Spanking new products builder for Stripe Billing (#117) - Thanks to @renchap for suggesting this and to @henryaj for reviewing it.

## 1.3.0 (2018-07-23)

* do not create new product when product id is provided (#115) - Thanks to @renchap for reporting this
* updates travis to latest rubies (#112) - Note that after this change we will only run tests on Ruby 2.5, 2.4 and 2.3


## 1.2.2 (2018-04-16)

* adds callback form `customer.source.expiring`. Thanks @Japestrale!

## 1.2.1 (2018-03-22)

* Fixes Stripe API update on 2018-02-05 that breaks the plan builder (thanks to @georgecheng for reporting this!)

## 1.2.0 (2018-01-02)

* Added additional callbacks (thanks @lloydpick & @dja)

## 1.1.2 (2017-10-25)

* Fixes js partial crash if stripe_js_version is not defined

## 1.1.1 (2017-08-31)

* Make stripe-ruby-mock an optional dependency (thanks @gaffneyc)

## 1.1.0 (2017-08-29)

* Adds a testing module for testing callbacks (thanks @Pyo25)
* Fixes loading with ActionController::API (thanks @gaffneyc)
* Fixes `NoMethodError: NoMethodError (undefined method `object' for #ActionController::Parameters` (thanks to a whole bunch of people for reporting this)

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
