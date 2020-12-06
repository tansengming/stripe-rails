# Stripe::Rails: A Rails Engine for use with [stripe.com](https://stripe.com)
[![Gem Version](https://badge.fury.io/rb/stripe-rails.svg)](https://badge.fury.io/rb/stripe-rails)
[![Build Status](https://travis-ci.org/tansengming/stripe-rails.svg?branch=master)](https://travis-ci.org/tansengming/stripe-rails)
[![Code Climate](https://codeclimate.com/github/tansengming/stripe-rails/badges/gpa.svg)](https://codeclimate.com/github/tansengming/stripe-rails)
[![Test Coverage](https://codeclimate.com/github/tansengming/stripe-rails/badges/coverage.svg)](https://codeclimate.com/github/tansengming/stripe-rails/coverage)
[![Tidelift](https://tidelift.com/badges/github/tansengming/stripe-rails)](#)

This gem can help your rails application integrate with Stripe in the following ways

* manage stripe configurations in a single place.
* makes stripe.js available from the asset pipeline.
* manage product, prices, plans and coupons from within your app.
* painlessly receive and validate webhooks from stripe.

[📫 Sign up for the Newsletter](http://tinyletter.com/stripe-rails) to receive occasional updates.

[Professionally supported stripe-rails is coming soon](https://tidelift.com/subscription/pkg/rubygems-stripe-rails?utm_source=rubygems-stripe-rails&utm_medium=referral&utm_campaign=readme)

---

[Installation](#installation)
- [Setup your API keys](#setup-your-api-keys)
- [Manually set your API version (optional)](#manually-set-your-api-version-optional)

[Setup your payment configuration](#setup-your-payment-configuration)
- [Configuring your plans and coupons](#configuring-your-plans-and-coupons)

[Stripe Elements](#stripe-elements)

[Webhooks](#webhooks)

- [Signed Webhooks](#signed-webhooks)
  - [Testing Signed Webhooks Locally](#testing-signed-webhooks-locally)
- [Disabling auto mount](#disabling-auto-mount)
- [Responding to webhooks](#responding-to-webhooks)
- [Critical and non-critical hooks](#critical-and-non-critical-hooks)
- [Filtering Callbacks](#filtering-callbacks)
- [Catchall Callback](#catchall-callback)

[Unit testing](#unit-testing)

[Thanks](#thanks)

[Code of Conduct](#code-of-conduct)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stripe-rails'
```

If you are going to be using [stripe.js][1] to securely collect credit card information
on the client, then you will need to add the stripe javascript tags into your template.
stripe-rails provides a helper to make this easy:

```erb
<%= stripe_javascript_tag %>
```

or, you can render it as a partial:

```erb
<%= render :partial => 'stripe/js' %>
```

In both cases, stripe-rails will choose a version of stripe.js appropriate for your
development environment and automatically configure it to use
your publishable API key. By default it uses `stripe-debug.js` for your `development`
environment and `stripe.js` for everything else, but you can manually configure it
per environment.

```ruby
config.stripe.debug_js = true  # use stripe-debug.js
config.stripe.debug_js = false # use stripe.js
```

By default the helper renders the `v3` version of `stripe.js`. You can provide an
alternate version to the helper to generate the appropriate tag:

```erb
<%= stripe_javascript_tag(:v2) %>
```

### Setup your API keys.

You will need to configure your application to authenticate with stripe.com
using [your api key][1]. There are two methods to do this, you can either set the environment
variable `STRIPE_SECRET_KEY`:

```sh
export STRIPE_SECRET_KEY=sk_test_xxyyzz
```

or if you are on heroku:

```sh
heroku config:add STRIPE_SECRET_KEY=sk_test_xxyyzz
```

You can also set this value from inside ruby configuration code:

```ruby
config.stripe.secret_key = "sk_test_xxyyzz"
```

In either case, it is recommended that you *not* check in this value into source control.

You can verify that your api is set up and functioning properly by running the following command:

```sh
rake stripe:verify
```

If you are going to be using stripe.js, then you will also need to set the value of your
publishable key. A nice way to do it is to set your test publishable for all environments:

```ruby
# config/application.rb
# ...
config.stripe.publishable_key = 'pk_test_XXXYYYZZZ'
```

And then override it to use your live key in production only

```ruby
# config/environments/production.rb
# ...
config.stripe.publishable_key = 'pk_live_XXXYYYZZZ'
```

This key will be publicly visible on the internet, so it is ok to put in your source. If
you prefer to environment variables, you can also set `STRIPE_PUBLISHABLE_KEY`:

```sh
export STRIPE_PUBLISHABLE_KEY=pk_test_XXXYYYZZZ
```

If no API key is provided, `stripe-rails` will show a warning: "No stripe.com API key was configured ...". You can silence this warning by setting the `ignore_missing_secret_key` option to `true`:

```ruby
# config/environments/production.rb
# ...
config.stripe.ignore_missing_secret_key = true
```

### Manually set your API version (optional)

If you need to test a new API version in development, you can override the version number manually.

```ruby
# config/environments/development.rb
# ...
config.stripe.api_version = '2015-10-16'
```

## Setup your payment configuration

If you're using subscriptions, then you'll need to set up your application's payment plans
and discounts. `Stripe::Rails` lets you automate the management of these definitions from
within the application itself. To get started:

```sh
rails generate stripe:install
```

this will generate the configuration files containing your plan and coupon definitions:

```console
create  config/stripe/products.rb
create  config/stripe/plans.rb
create  config/stripe/prices.rb
create  config/stripe/coupons.rb
```

### Configuring your plans and coupons

Use the plan builder to define as many plans as you want in `config/stripe/plans.rb`

```ruby
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

Stripe.plan :bronze do |plan|
  # Use an existing product id to prevent a new plan from
  # getting created
  plan.product_id = 'prod_XXXXXXXXXXXXXX'
  plan.amount = 999 # $9.99
  plan.interval = 'month'

  # Use graduated pricing tiers
  # ref: https://stripe.com/docs/api/plans/object#plan_object-tiers
  plan.tiers = [
    {
      unit_amount: 1500,
      up_to: 10
    },
    {
      unit_amount: 1000,
      up_to: 'inf'
    }
  ]
  plan.tiers_mode = 'graduated'

  # set the usage type to 'metered'
  plan.usage_type = 'metered'
end
```

This will define constants for these plans in the Stripe::Plans module so that you
can refer to them by reference as opposed to an id string.

```ruby
Stripe::Plans::SILVER # => 'silver: ACME Silver'
Stripe::Plans::GOLD # => 'gold: ACME Gold'
```

If you have to support an existing plan with a Stripe plan id that can not
be used as a Ruby constant, provide the plan id as a symbol when
defining the plan, but provide the name for the constant to define with `constant_name`:

```ruby
Stripe.plan "Silver-Plan".to_sym do |plan|
  plan.constant_name = 'SILVER_PLAN' # <---
  plan.name = 'ACME Silver'
  plan.amount = 699
  plan.interval = 'month'
end

Stripe::Plans::SILVER_PLAN # => will be defined
# Will map to plan :id => "Silver-Plan" on Stripe
```

**Note** - If you're planning on running `rake stripe:prepare` to
  create your subscription plans, Stripe will restrict plan ids to match
  this regexp (`/\A[a-zA-Z0-9_\-]+\z/`) when created via API but still
  allows creation of plan ids that don't follow this restriction when
  manually created on stripe.com.

Coupons are created in much the same way:

```ruby
Stripe.coupon :super_elite_free_vip do |coupon|
  coupon.duration = 'forever'
  coupon.percent_off = 100
  coupon.max_redemptions = 5
end
```


As are Products:

```ruby
Stripe.product :primo do |product|
  product.name = 'PRIMO as a service'
  product.type = 'service'
  product.statement_descriptor = 'PRIMO'
end
```

And Prices:

```ruby
Stripe.price :bronze do |price|
  # Use an existing product id to prevent a new product from
  # getting created
  price.product_id = Stripe::Products::PRIMO.id
  price.billing_scheme = 'tiered'
  price.recurring = {
    interval: 'month',
    usage_type: 'metered'
  }

  # Use graduated pricing tiers
  # ref: https://stripe.com/docs/api/prices/object#price_object-tiers
  price.tiers = [
    {
      unit_amount: 1500,
      up_to: 10
    },
    {
      unit_amount: 1000,
      up_to: 'inf'
    }
  ]
  price.tiers_mode = 'graduated'
end
````

To upload your plans, products, prices and coupons onto stripe.com, run:

```sh
rake stripe:prepare
```

This will create any plans, products, prices and coupons that do not currently exist, and treat as a NOOP any
objects that already exist, so you can run this command safely as many times as you wish. Now you can
use any of these objects in your application.

NOTE: You must destroy plans and prices manually from your stripe dashboard.

## Stripe Elements

Stripe::Rails allows you to easily include [Stripe Elements](https://stripe.com/payments/elements) in your application.

> Stripe Elements are rich, pre-built UI components that help you create your own pixel-perfect checkout flows across desktop and mobile.

Simply include the `stripe_elements_tag` anywhere below the `stripe_javascript_tag` and pass it the path to the controller action which will handle the Stripe token once the form is submitted:

```erb
<%= stripe_javascript_tag %>
<%= stripe_elements_tag submit_path: billing_path %>
```

### Configuration options

Stripe::Rails comes bundled with default CSS and Javascript for Stripe elements, making it easy to drop in to your app. You can also specify your own assets paths:

```erb
<%= stripe_elements_tag submit_path: billing_path,
                        css_path: 'your/asset/path',
                        js_path: 'your/asset/path' %>
```

If you decide to use your own CSS and Javascript for Stripe Elements, please refer to the [Stripe elements docs](https://stripe.com/docs/stripe-js/elements/quickstart).

To change the form text you can add the following keys to your locale files

```yaml
# config/locales/en.yml
en:
  stripe_rails:
    elements:
      label_text: Your label text
      submit_button_text: Your button text
```

## Webhooks

Stripe::Rails automatically sets up your application to receive webhooks from stripe.com whenever
a payment event is generated. To enable this, you will need to configure your [stripe webhooks][3] to
point back to your application. By default, the webhook controller is mounted at '/stripe/events' so
you would want to enter in `http://myproductionapp.com/stripe/events` as your url for live mode,
and `http://mystagingapp.com/stripe/events` for your test mode.

If you want to mount the stripe engine somewhere else, you can do so by setting the `stripe.endpoint`
parameter. E.g.

```ruby
config.stripe.endpoint = '/payment/stripe-integration'
```

Your new webhook URL would then be `http://myproductionapp/payment/stripe-integration/events`

### Signed Webhooks

Validation of your webhook's signature uses your webhook endpoint signing secret.
Before you can verify signatures, you need to retrieve your endpoint’s secret from your
Stripe Dashboard. Select an endpoint for which you want to obtain
the secret, then select the Click to reveal button.

```ruby
# config/application.rb
# ...
config.stripe.signing_secrets = ['whsec_XXXYYYZZZ']
```

Each secret is unique to the endpoint to which it corresponds. If you use multiple endpoint,
you must obtain a secret for each one. After this setup, Stripe starts to sign each webhook
it sends to the endpoint. Because of this, we recommend setting this variable with environment
variables:

```sh
export STRIPE_SIGNING_SECRET=whsec_XXXYYYZZZ
export STRIPE_CONNECT_SIGNING_SECRET=whsec_AAABBBCCC
```

```ruby
config.stripe.signing_secrets = [ENV.fetch('STRIPE_SIGNING_SECRET'), ENV.fetch('STRIPE_CONNECT_SIGNING_SECRET')]
```

The first secret that successfully matches for each incoming webhook will be used to verify the incoming events.

#### Testing Signed Webhooks Locally

In order to test signed webhooks, you'll need to trigger test webhooks from your Stripe dashboard,
and configure your local environment to receive remote network requests. To do so, we recommend using
[ngrok](https://ngrok.com/) to configure a secure tunnel to `localhost`.

Once configured and running, `ngrok` will give you a unique URL which can be used to set up a webhook
endpoint. Webhook endpoints are configured in your Dashboard's [Webhook settings](https://dashboard.stripe.com/account/webhooks)
section. Make sure you are in **Test** mode and click `Add endpoint`, and provide your `ngrok` URL along with the `stripe.endpoint` suffix.

An example webhook URL would then be `https://bf2a5d21.ngrok.io/stripe/events`.

Once your endpoint is configured, you can reveal the **Signing secret**. This will need to be set
as documented above:

```ruby
# config/application.rb
# ...
config.stripe.signing_secrets = ['whsec_XXXYYYZZZ']
```

And you'll need to restart your rails server with:

```sh
rails restart
```

Now you're ready to click **Send test webhook**, and trigger whichever events you'd like to test from Stripe itself.

### Disabling auto mount

Sometimes, you don't want the stripe engine to be auto-mounted so that
you control *exactly* what priority it will take in your routing
table. This is especially important if you have a catch-all route
which should appear after all other routes. In order to disable
auto-mounting of the Stripe engine:

```ruby
# in application.rb
config.stripe.auto_mount = false
```

Then, you will have to manually mount the engine in your main application.

```ruby
# in your application's routes.rb:
mount Stripe::Engine => "/stripe"
```

### Responding to webhooks

Once you have your webhook URL configured you can respond to a stripe webhook *anywhere* in your
application just by including the Stripe::Callbacks module into your class and declaring a
callback with one of the callback methods. For example, to update a customer's payment status:

```ruby
class User < ActiveRecord::Base
  include Stripe::Callbacks

  after_customer_updated! do |customer, event|
    user = User.find_by_stripe_customer_id(customer.id)
    if customer.delinquent
      user.is_account_current = false
      user.save!
    end
  end
end
```

or to send an email with one of your customer's monthly invoices

```ruby
class InvoiceMailer < ActionMailer::Base
  include Stripe::Callbacks

  after_invoice_created! do |invoice, event|
    user = User.find_by_stripe_customer(invoice.customer)
    new_invoice(user, invoice).deliver
  end

  def new_invoice(user, invoice)
    @user = user
    @invoice = invoice
    mail :to => user.email, :subject => '[Acme.com] Your new invoice'
  end
end
```

**Note:** `Stripe::Callbacks` won't get included until the including class has been loaded. This is usually not an issue in the production environment as eager loading is enabled by default (`config.eager_load = true`). You may run into an issue in your development environment where eager loading is disabled by default.

If you don't wish to enable eager loading in development, you can configure the classes to be eager loaded like so

```ruby
# in your application's config/environments/development.rb
config.stripe.eager_load = 'account', 'module/some_class', 'etc'
```
This will ensure that callbacks will get loaded in those configured classes if eager loading is disabled.

The naming convention for the callback events is after__{callback_name}! where `callback_name`
is name of the stripe event with all `.` characters substituted with underscores. So, for
example, the stripe event `customer.discount.created` can be hooked by `after_customer_discount_created!`
and so on...

Each web hook is passed an instance of the stripe object to which the event corresponds
([`Stripe::Customer`][8], [`Stripe::Invoice`][9], [`Stripe::Charge`][10], etc...) as well as the [`Stripe::Event`][4] which contains metadata about the event being raised.

By default, the event is re-fetched securely from stripe.com to prevent damage to your system by
a malicious system spoofing real stripe events.



### Critical and non-critical hooks

So far, the examples have all used critical hooks, but in fact, each callback method comes in two flavors: "critical",
specified with a trailing `!` character, and "non-critical", which has no "bang" character at all. What
distinguishes one from the other is that _if an exception is raised in a critical callback, it will cause the entire webhook to fail_.

This will indicate to stripe.com that you did not receive the webhook at all, and that it should retry it again later until it
receives a successful response. On the other hand, there are some tasks that are more tangential to the payment work flow and aren't
such a big deal if they get dropped on the floor. For example, A non-critical hook can be used to do things like have a bot
notify your company's chatroom that something a credit card was successfully charged:

```ruby
class AcmeBot
  include Stripe::Callbacks

  after_charge_succeeded do |charge|
    announce "Attention all Dudes and Dudettes. Ya'll are so PAID!!!"
  end
end
```

Chances are that if you experience a momentary failure in connectivity to your chatroom, you don't want the whole payment notification to fail.


### Filtering Callbacks

Certain stripe events represent updates to existing data. You may want to only fire the event when certain attributes of that data
are updated. You can pass an `:only` option to your callback to filter to specify which attribute updates you're interested in. For
example, to warn users whenever their credit card has changed:

```ruby
class StripeMailer
  include Stripe::Callbacks

  after_customer_updated! :only => :active_card do |customer, evt|
    your_credit_card_on_file_was_updated_are_you_sure_this_was_you(customer).deliver
  end
end
```

Filters can be specified as an array as well:

```ruby
module Accounting
  include Stripe::Callbacks

  after_invoice_updated! :only => [:amount, :subtotal] do
    # update our records
  end
end
```

Alternatively, you can just pass a proc to filter the event manually. It will receive an instance of [`Stripe::Event`][4] as
its parameter:

```ruby
module StagingOnly
  include Stripe::Callbacks

  after_charge_succeeded! :only => proc {|charge, evt| unless evt.livemode} do |charge|
    puts "FAKE DATA, PLEASE IGNORE!"
  end
end
```

### Catchall Callback

The special 'stripe.event' callback will be invoked for every single event received from stripe.com. This can be useful for things
like logging and analytics:

```ruby
class StripeFirehose
  include Stripe::Callbacks

  after_stripe_event do |target, event|
    # do something useful
  end
end
```

See the [complete listing of all stripe events][5], and the [webhook tutorial][6] for more great information on this subject.

## Unit testing

If you want to test your callbacks, you can use the `Stripe::Rails::Testing` module to send mocked Stripe events.

```ruby
require 'stripe/rails/testing'
test "my callback handles new subscription" do
  Stripe::Rails::Testing.send_event "customer.subscription.created"
  # Assertions
end
```

You can also overwrite some event properties: ([More info](https://github.com/rebelidealist/stripe-ruby-mock#customizing-webhooks))

```ruby
require 'stripe/rails/testing'
test "my callback handles new subscription" do
  Stripe::Rails::Testing.send_event "customer.subscription.created", {
    :email => "john@doe.com",
    :account_balance => 40
  }
  # Assertions
end
```

The default fixtures come from [the `stripe-ruby-mock` gem](https://github.com/rebelidealist/stripe-ruby-mock/tree/master/lib/stripe_mock/webhook_fixtures).

## Thanks

<a href="http://frontside.io">![Frontside](http://frontside.io/images/logo.svg)</a>

`Stripe::Rails` was originally developed with love and fondness by your friends at [Frontside][7]. They are available for your custom software development needs, including integration with stripe.com.

<a href="https://www.evercondo.com">![Evercondo](https://dl.dropboxusercontent.com/s/m3ma9356uelep53/evercondo.png)</a>

`Stripe::Rails` has also been supported by the fine folks at [Evercondo][11], the next generation condo management software.


[1]: https://stripe.com/docs/stripe.js
[2]: https://manage.stripe.com/#account/apikeys
[3]: https://manage.stripe.com/#account/webhooks
[4]: https://stripe.com/docs/api?lang=ruby#events
[5]: https://stripe.com/docs/api?lang=ruby#event_types
[6]: https://stripe.com/docs/webhooks
[7]: http://frontside.io
[8]: https://stripe.com/docs/api?lang=ruby#customers
[9]: https://stripe.com/docs/api?lang=ruby#invoices
[10]: https://stripe.com/docs/api?lang=ruby#charges
[11]: https://www.evercondo.com


## Code of Conduct

Please note that this project is released with a Contributor Code of
Conduct. By participating in this project you agree to abide by its
terms, which can be found in the `CODE_OF_CONDUCT.md` file in this
repository.
