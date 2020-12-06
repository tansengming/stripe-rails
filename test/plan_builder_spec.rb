require 'spec_helper'

describe 'building plans' do
  describe 'simply' do
    before do
      Stripe.plan :primo do |plan|
        plan.name = 'Acme as a service PRIMO'
        plan.amount = 699
        plan.interval = 'month'
        plan.interval_count = 3
        plan.trial_period_days = 30
        plan.metadata = {:number_of_awesome_things => 5}
        plan.statement_descriptor = 'Acme Primo'
        plan.active = true
        plan.nickname = 'primo'
        plan.usage_type = 'metered'
        plan.billing_scheme = 'per_unit'
        plan.aggregate_usage = 'sum'
        plan.tiers_mode = 'graduated'
      end
    end

    after { Stripe::Plans.send(:remove_const, :PRIMO) }

    it 'is accessible via id' do
      _(Stripe::Plans::PRIMO).wont_be_nil
    end

    it 'is accessible via collection' do
      _(Stripe::Plans.all).must_include Stripe::Plans::PRIMO
    end

    it 'is accessible via hash lookup (symbol/string agnostic)' do
      _(Stripe::Plans[:primo]).must_equal Stripe::Plans::PRIMO
      _(Stripe::Plans['primo']).must_equal Stripe::Plans::PRIMO
    end

    it 'accepts a billing interval of a day' do
      Stripe.plan :daily do |plan|
        plan.name = 'Acme as a service daily'
        plan.amount = 100
        plan.interval = 'day'
      end

      _(Stripe::Plans::DAILY).wont_be_nil
    end

    it 'accepts a billing interval of a week' do
      Stripe.plan :weekly do |plan|
        plan.name = 'Acme as a service weekly'
        plan.amount = 100
        plan.interval = 'week'
      end

      _(Stripe::Plans::WEEKLY).wont_be_nil
    end

    it 'accepts a billing interval of a month' do
      Stripe.plan :monthly do |plan|
        plan.name = 'Acme as a service monthly'
        plan.amount = 400
        plan.interval = 'month'
      end

      _(Stripe::Plans::MONTHLY).wont_be_nil
    end

    it 'accepts a billing interval of a year' do
      Stripe.plan :yearly do |plan|
        plan.name = 'Acme as a service yearly'
        plan.amount = 4800
        plan.interval = 'year'
      end

      _(Stripe::Plans::YEARLY).wont_be_nil
    end

    it 'denies arbitrary billing intervals' do
      _(lambda {
        Stripe.plan :broken do |plan|
          plan.name = 'Acme as a service BROKEN'
          plan.amount = 999
          plan.interval = 'anything'
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'accepts a statement descriptor' do
      Stripe.plan :described do |plan|
        plan.name = 'Acme as a service'
        plan.amount = 999
        plan.interval = 'month'
        plan.statement_descriptor = 'ACME Monthly'
      end

      _(Stripe::Plans::DESCRIBED).wont_be_nil
    end

    it 'denies statement descriptors that are too long' do
      _(lambda {
        Stripe.plan :described do |plan|
          plan.name = 'Acme as a service'
          plan.amount = 999
          plan.interval = 'month'
          plan.statement_descriptor = 'ACME as a Service Monthly'
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'denies invalid values for active' do
      _(lambda {
        Stripe.plan :broken do |plan|
          plan.name = 'Acme as a service'
          plan.amount = 999
          plan.interval = 'month'
          plan.active = 'whatever'
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'denies invalid values for usage_type' do
      _(lambda {
        Stripe.plan :broken do |plan|
          plan.name = 'Acme as a service'
          plan.amount = 999
          plan.interval = 'month'
          plan.usage_type = 'whatever'
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'denies invalid values for aggregate_usage' do
      _(lambda {
        Stripe.plan :broken do |plan|
          plan.name = 'Acme as a service'
          plan.amount = 999
          plan.interval = 'month'
          plan.aggregate_usage = 'whatever'
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'denies aggregate_usage if usage type is licensed' do
      _(lambda {
        Stripe.plan :broken do |plan|
          plan.name = 'Acme as a service'
          plan.amount = 999
          plan.interval = 'month'
          plan.usage_type = 'licensed'
          plan.aggregate_usage = 'sum'
        end
      }).must_raise Stripe::InvalidConfigurationError
    end


    it 'denies invalid values for billing_scheme' do
      _(lambda {
        Stripe.plan :broken do |plan|
          plan.name = 'Acme as a service'
          plan.amount = 999
          plan.interval = 'month'
          plan.billing_scheme = 'whatever'
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'denies invalid values for tiers_mode' do
      _(lambda {
        Stripe.plan :broken do |plan|
          plan.name = 'Acme as a service'
          plan.amount = 999
          plan.interval = 'month'
          plan.tiers_mode = 'whatever'
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    describe 'name and product id validation' do
      it 'should be valid when using just the product id' do
        Stripe.plan :prodded do |plan|
          plan.product_id = 'acme'
          plan.amount = 999
          plan.interval = 'month'
        end
        _(Stripe::Plans::PRODDED).wont_be_nil
      end

      it 'should be invalid when using both name and product id' do
        _(lambda {
          Stripe.plan :broken do |plan|
            plan.name = 'Acme as a service'
            plan.product_id = 'acme'
            plan.amount = 999
            plan.interval = 'month'
          end
        }).must_raise Stripe::InvalidConfigurationError
      end
    end

    describe 'uploading' do
      include FixtureLoader

      describe 'when none exists on stripe.com' do
        let(:headers) { load_request_fixture('stripe_plans_headers_2017.json') }
        before do
          Stripe::Plan.stubs(:retrieve).raises(Stripe::InvalidRequestError.new("not found", "id"))

          stub_request(:get, "https://api.stripe.com/v1/plans").
            with(headers: { 'Authorization'=>'Bearer XYZ',}).
            to_return(status: 200, body: load_request_fixture('stripe_plans.json'), headers: JSON.parse(headers))
        end

        it 'creates the plan online' do
          Stripe::Plan.expects(:create).with(
            :id => :gold,
            :currency => 'usd',
            :name => 'Solid Gold',
            :amount => 699,
            :interval => 'month',
            :interval_count => 1,
            :trial_period_days => 0
          )
          Stripe::Plans::GOLD.put!
        end

        it 'creates a plan with an alternative currency' do
          Stripe::Plan.expects(:create).with(
            :id => :alternative_currency,
            :currency => 'cad',
            :name => 'Alternative Currency',
            :amount => 699,
            :interval => 'month',
            :interval_count => 1,
            :trial_period_days => 0
          )
          Stripe::Plans::ALTERNATIVE_CURRENCY.put!
        end

        describe 'when using the API version that supports products' do
          before { Stripe.api_version = '2018-02-05' }
          after  { Stripe.api_version = nil }

          it 'creates the plan online' do
            Stripe::Plan.expects(:create).with(
              :id => :gold,
              :currency => 'usd',
              :product => {
                :name => 'Solid Gold',
                :statement_descriptor => nil,
              },
              :amount => 699,
              :interval => 'month',
              :interval_count => 1,
              :trial_period_days => 0
            )
            Stripe::Plans::GOLD.put!
          end

          it 'creates a metered plan' do
            Stripe::Plan.expects(:create).with(
              :id => :metered,
              :currency => 'usd',
              :product => {
                :name => 'Metered',
                :statement_descriptor => nil,
              },
              :amount => 699,
              :interval => 'month',
              :interval_count => 1,
              :trial_period_days => 0,
              :usage_type => 'metered',
              :aggregate_usage => 'max',
              :billing_scheme => 'per_unit'
            )
            Stripe::Plans::METERED.put!
          end

          it 'creates a tiered plan' do
            Stripe::Plan.expects(:create).with(
              :id => :tiered,
              :currency => 'usd',
              :product => {
                :name => 'Tiered',
                :statement_descriptor => nil,
              },
              :interval => 'month',
              :interval_count => 1,
              :trial_period_days => 0,
              :usage_type => 'metered',
              :aggregate_usage => 'max',
              :billing_scheme => 'tiered',
              :tiers => [
                {
                  :unit_amount => 1500,
                  :up_to => 10
                },
                {
                  :unit_amount => 1000,
                  :up_to => 'inf'
                }
              ],
              :tiers_mode => 'graduated'
            )
            plan = Stripe::Plans::TIERED
            Stripe::Plans::TIERED.put!
          end

          describe 'when passed invalid arguments for tiered pricing' do
            it 'raises a Stripe::InvalidConfigurationError when billing tiers are invalid' do
              lambda {
                Stripe.plan "Bad Tiers".to_sym do |plan|
                  plan.name = 'Acme as a service BAD TIERS'
                  plan.constant_name = 'BAD_TIERS'
                  plan.interval = 'month'
                  plan.interval_count = 1
                  plan.trial_period_days = 30
                  plan.usage_type = 'metered'
                  plan.tiers_mode = 'graduated'
                  plan.billing_scheme = 'per_unit'
                  plan.aggregate_usage = 'sum'
                  plan.tiers = [
                    {
                      unit_amount: 1500,
                      up_to: 10
                    },
                    {
                      unit_amount: 1000,
                    }
                  ]
                end
              }.must_raise Stripe::InvalidConfigurationError
            end

            it 'raises a Stripe::InvalidConfigurationError when billing tiers is not an array' do
              lambda {
                Stripe.plan "Bad Tiers".to_sym do |plan|
                  plan.name = 'Acme as a service BAD TIERS'
                  plan.constant_name = 'BAD_TIERS'
                  plan.interval = 'month'
                  plan.interval_count = 1
                  plan.trial_period_days = 30
                  plan.usage_type = 'metered'
                  plan.tiers_mode = 'graduated'
                  plan.billing_scheme = 'per_unit'
                  plan.aggregate_usage = 'sum'
                  plan.tiers = {
                    unit_amount: 1500,
                    up_to: 10
                  }
                end
              }.must_raise Stripe::InvalidConfigurationError
            end
          end

          describe 'when using a product id' do
            before do
              Stripe::Plans::GOLD.product_id = 'prod_XXXXXXXXXXXXXX'
              Stripe::Plans::GOLD.name = nil
            end
            after do
              Stripe::Plans::GOLD.product_id = nil
              Stripe::Plans::GOLD.name = 'Solid Gold'
            end

            it 'creates the plan online with the product id' do
              Stripe::Plan.expects(:create).with(
                :id => :gold,
                :currency => 'usd',
                :product => 'prod_XXXXXXXXXXXXXX',
                :amount => 699,
                :interval => 'month',
                :interval_count => 1,
                :trial_period_days => 0
              )
              Stripe::Plans::GOLD.put!
            end
          end
        end

        describe 'when api_version is not set for api versions that support products' do
          before  { Stripe.api_version = nil }
          subject { Stripe::Plans::GOLD.put! }
          let(:headers) { load_request_fixture('stripe_plans_headers.json') }

          it 'creates the plan online' do
            Stripe::Plan.expects(:create).with(
              :id => :gold,
              :currency => 'usd',
              :product => {
                :name => 'Solid Gold',
                :statement_descriptor => nil,
              },
              :amount => 699,
              :interval => 'month',
              :interval_count => 1,
              :trial_period_days => 0
            )

            subject
          end
        end
      end

      describe 'when it is already present on stripe.com' do
        before do
          Stripe::Plan.stubs(:retrieve).returns(Stripe::Plan.construct_from({
            :id => :gold,
            :name => 'Solid Gold'
          }))
        end

        it 'is a no-op' do
          Stripe::Plan.expects(:create).never
          Stripe::Plans::GOLD.put!
        end
      end
    end
  end

  describe 'with missing mandatory values' do
    it 'raises an exception after configuring it' do
      _(-> { Stripe.plan(:bad) {} }).must_raise Stripe::InvalidConfigurationError
    end
  end

  describe 'with custom constant name' do
    before do
      Stripe.plan "Primo Plan".to_sym do |plan|
        plan.name = 'Acme as a service PRIMO'
        plan.constant_name = 'PRIMO_PLAN'
        plan.amount = 699
        plan.interval = 'month'
        plan.interval_count = 3
        plan.trial_period_days = 30
        plan.metadata = {:number_of_awesome_things => 5}
        plan.statement_descriptor = 'Acme Primo'
        plan.active = true
        plan.nickname = 'primo'
        plan.usage_type = 'metered'
        plan.billing_scheme = 'per_unit'
        plan.aggregate_usage = 'sum'
        plan.tiers_mode = 'graduated'
      end
    end

    after { Stripe::Plans.send(:remove_const, :PRIMO_PLAN) }

    it 'is accessible via upcased constant_name' do
      _(Stripe::Plans::PRIMO_PLAN).wont_be_nil
    end

    it 'is accessible via collection' do
      _(Stripe::Plans.all).must_include Stripe::Plans::PRIMO_PLAN
    end

    it 'is accessible via hash lookup (symbol/string agnostic)' do
      _(Stripe::Plans[:primo_plan]).must_equal Stripe::Plans::PRIMO_PLAN
      _(Stripe::Plans['primo_plan']).must_equal Stripe::Plans::PRIMO_PLAN
    end

    describe 'constant name validation' do
      it 'should be invalid when providing a constant name that can not be used for Ruby constant' do
        _(lambda {
          Stripe.plan "Primo Plan".to_sym do |plan|
            plan.name = 'Acme as a service PRIMO'
            plan.constant_name = 'PRIMO PLAN'
            plan.amount = 999
            plan.interval = 'month'
          end
        }).must_raise Stripe::InvalidConfigurationError
      end
    end

    describe 'uploading' do
      include FixtureLoader

      describe 'when none exists on stripe.com' do
        let(:headers) { load_request_fixture('stripe_plans_headers_2017.json') }
        before do
          Stripe::Plan.stubs(:retrieve).raises(Stripe::InvalidRequestError.new("not found", "id"))

          stub_request(:get, "https://api.stripe.com/v1/plans").
            with(headers: { 'Authorization'=>'Bearer XYZ',}).
            to_return(status: 200, body: load_request_fixture('stripe_plans.json'), headers: JSON.parse(headers))
        end

        it 'creates the plan online' do
          Stripe::Plan.expects(:create).with(
            :id => "Solid Gold".to_sym,
            :currency => 'usd',
            :name => 'Solid Gold',
            :amount => 699,
            :interval => 'month',
            :interval_count => 1,
            :trial_period_days => 0
          )
          Stripe::Plans::SOLID_GOLD.put!
        end
      end
    end
  end
end
