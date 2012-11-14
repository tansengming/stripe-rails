# Stripe::Rails: A Full-Featured Rails Engine for Use with stripe.com

[stripe.com](http://stripe.com) integration for your rails application

## Installation

Add this line to your application's Gemfile:

    gem 'stripe-rails'

If you are going to be using [stripe.js][1] to securely collect credit card information
on the client, then add the following to app/assets/javascripts/application.js

    //= require stripe

### Setup your API keys.

You will need to configure your application to authenticate with stripe.com
using [your api key][1]. There are two methods to do this, you can either set the environment
variable `STRIPE_API_KEY`, or use the rails configuration setting `config.stripe.api_key`.
In either case, it is recommended that you *not* check in this value into source control.

Once you can verify that your api is set up and functioning properly by running the following command:

    rake stripe:verify

If you are going to be using stripe.js, then you will also need to set the value of your
publishiable key. A nice way to do it is to set your test publishable for all environments:

    # config/application.rb
    # ...
    config.stripe.publishable_key = 'pk_test_XXXYYYZZZ'

And then override it to use your live key in production only

    # config/environments/production.rb
    # ...
    config.stripe.publishable_key = 'pk_live_XXXYYYZZZ'

This key will be publicly visible on the internet, so it is ok to put in your source.

### Setup your payment configuration

If you're using subscriptions, then you'll need to set up your application's payment plans
and discounts. `Stripe::Rails` lets you automate the management of these definitions from
within the application itself. To get started:

    rails generate stripe:install

this will generate the configuration files containing your plan and coupon definitions:

      create  config/stripe/plans.rb
      create  config/stripe/coupons.rb

### Configuring your plans

Use the plan builder to define as many plans as you want in `config/stripe/plans.rb`

    Stripe.plan :silver do |plan|
      plan.name = 'ACME Silver'
      plan.amount = 699 # $6.99
      plan.interval = 'month'
    end

    Stripe.plan :gold do |plan|
      plan.name = 'ACME Gold'
      plan.amount = 999 # $9.99
      plan.interval = 'month'
    end

This will define constants for these plans in the Stripe::Plans module so that you
can refer to them by reference as opposed to an id string.

    Stripe::Plans::SILVER # => 'silver: ACME Silver'
    Stripe::Plans::GOLD # => 'gold: ACME Gold'

To upload these plans onto stripe.com, run:

    rake stripe:prepare

This will create any plans that do not currently exist, and treat as a NOOP any
plans that do, so you can run this command safely as many times as you wish.

NOTE: You must destroy plans manually from your stripe dashboard.

## Usage

[1]: https://stripe.com/docs/stripe.js
[2]: https://manage.stripe.com/#account/apikeys