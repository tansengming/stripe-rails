require 'spec_helper'

describe 'building prices' do
  describe 'simply' do
    before do
      Stripe.price :lite do |price|
        price.name = 'Acme as a service LITE'
        price.unit_amount = 699
        price.recurring = {
          interval: 'month',
          interval_count: 3,
          usage_type: 'metered',
          aggregate_usage: 'sum'
        }
        price.metadata = {:number_of_awesome_things => 5}
        price.statement_descriptor = 'Acme Lite'
        price.active = true
        price.nickname = 'lite'
        price.billing_scheme = 'per_unit'
        price.tiers_mode = 'graduated'
      end
    end

    after { Stripe::Prices.send(:remove_const, :LITE) }

    it 'is accessible via id' do
      _(Stripe::Prices::LITE).wont_be_nil
    end

    it 'is accessible via collection' do
      _(Stripe::Prices.all).must_include Stripe::Prices::LITE
    end

    it 'is accessible via hash lookup (symbol/string agnostic)' do
      _(Stripe::Prices[:lite]).must_equal Stripe::Prices::LITE
      _(Stripe::Prices['lite']).must_equal Stripe::Prices::LITE
    end

    it 'sets the lookup key' do
      _(Stripe::Prices::LITE.lookup_key).must_equal 'lite'
    end

    it 'accepts a billing interval of a day' do
      Stripe.price :daily do |price|
        price.name = 'Acme as a service daily'
        price.unit_amount = 100
        price.recurring = {
          interval: 'day'
        }
      end

      _(Stripe::Prices::DAILY).wont_be_nil
    end

    it 'denies a billing interval of a day and excessive intervals' do
      _(lambda {
        Stripe.price :broken do |price|
          price.name = 'Acme as a service daily'
          price.unit_amount = 100
          price.recurring = {
            interval: 'day',
            interval_count: 366
          }
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'accepts a billing interval of a week' do
      Stripe.price :weekly do |price|
        price.name = 'Acme as a service weekly'
        price.unit_amount = 100
        price.recurring = {
          interval: 'week'
        }
      end

      _(Stripe::Prices::WEEKLY).wont_be_nil
    end

    it 'denies a billing interval of a week and excessive intervals' do
      _(lambda {
        Stripe.price :broken do |price|
          price.name = 'Acme as a service weekly'
          price.unit_amount = 100
          price.recurring = {
            interval: 'week',
            interval_count: 53
          }
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'accepts a billing interval of a month' do
      Stripe.price :monthly do |price|
        price.name = 'Acme as a service monthly'
        price.unit_amount = 400
        price.recurring = {
          interval: 'month'
        }
      end

      _(Stripe::Prices::MONTHLY).wont_be_nil
    end

    it 'denies a billing interval of a month and excessive intervals' do
      _(lambda {
        Stripe.price :broken do |price|
          price.name = 'Acme as a service monthly'
          price.unit_amount = 400
          price.recurring = {
            interval: 'month',
            interval_count: 13
          }
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'accepts a billing interval of a year' do
      Stripe.price :yearly do |price|
        price.name = 'Acme as a service yearly'
        price.unit_amount = 4800
        price.recurring = {
          interval: 'year'
        }
      end

      _(Stripe::Prices::YEARLY).wont_be_nil
    end

    it 'denies a billing interval of a year and excessive intervals' do
      _(lambda {
        Stripe.price :broken do |price|
          price.name = 'Acme as a service yearly'
          price.unit_amount = 4800
          price.recurring = {
            interval: 'year',
            interval_count: 2
          }
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'denies arbitrary billing intervals' do
      _(lambda {
        Stripe.price :broken do |price|
          price.name = 'Acme as a service BROKEN'
          price.unit_amount = 999
          price.recurring = {
            interval: 'anything'
          }
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'accepts empty recurring options' do
      Stripe.price :singular do |price|
        price.name = 'Acme as a service one time'
        price.unit_amount = 888
      end

      _(Stripe::Prices::SINGULAR).wont_be_nil
    end

    it 'accepts a statement descriptor' do
      Stripe.price :described do |price|
        price.name = 'Acme as a service'
        price.unit_amount = 999
        price.recurring = {
          interval: 'month'
        }
        price.statement_descriptor = 'ACME Monthly'
      end

      _(Stripe::Prices::DESCRIBED).wont_be_nil
    end

    it 'denies statement descriptors that are too long' do
      _(lambda {
        Stripe.price :described do |price|
          price.name = 'Acme as a service'
          price.unit_amount = 999
          price.recurring = {
            interval: 'month'
          }
          price.statement_descriptor = 'ACME as a Service Monthly'
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'denies invalid values for active' do
      _(lambda {
        Stripe.price :broken do |price|
          price.name = 'Acme as a service'
          price.unit_amount = 999
          price.recurring = {
            interval: 'month'
          }
          price.active = 'whatever'
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'denies invalid values for usage_type' do
      _(lambda {
        Stripe.price :broken do |price|
          price.name = 'Acme as a service'
          price.unit_amount = 999
          price.recurring = {
            interval: 'month',
            usage_type: 'whatever'
          }
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'denies invalid values for aggregate_usage' do
      _(lambda {
        Stripe.price :broken do |price|
          price.name = 'Acme as a service'
          price.unit_amount = 999
          price.recurring = {
            interval: 'month',
            aggregate_usage: 'whatever'
          }
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'denies aggregate_usage if usage type is licensed' do
      _(lambda {
        Stripe.price :broken do |price|
          price.name = 'Acme as a service'
          price.unit_amount = 999
          price.recurring = {
            interval: 'month',
            usage_type: 'licensed',
            aggregate_usage: 'sum'
          }
        end
      }).must_raise Stripe::InvalidConfigurationError
    end


    it 'denies invalid values for billing_scheme' do
      _(lambda {
        Stripe.price :broken do |price|
          price.name = 'Acme as a service'
          price.unit_amount = 999
          price.recurring = {
            interval: 'month'
          }
          price.billing_scheme = 'whatever'
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    it 'denies invalid values for tiers_mode' do
      _(lambda {
        Stripe.price :broken do |price|
          price.name = 'Acme as a service'
          price.unit_amount = 999
          price.recurring = {
            interval: 'month'
          }
          price.tiers_mode = 'whatever'
        end
      }).must_raise Stripe::InvalidConfigurationError
    end

    describe 'name and product id validation' do
      it 'should be valid when using just the product id' do
        Stripe.price :prodded do |price|
          price.product_id = 'acme'
          price.unit_amount = 999
          price.recurring = {
            interval: 'month'
          }
        end
        _(Stripe::Prices::PRODDED).wont_be_nil
      end

      it 'should be invalid when using both name and product id' do
        _(lambda {
          Stripe.price :broken do |price|
            price.name = 'Acme as a service'
            price.product_id = 'acme'
            price.unit_amount = 999
            price.recurring = {
              interval: 'month'
            }
          end
        }).must_raise Stripe::InvalidConfigurationError
      end
    end

    describe 'uploading' do
      include FixtureLoader

      describe 'when none exists on stripe.com' do
        before do
          Stripe::Price.stubs(:list).returns(Stripe::Price.construct_from(data: []))

          stub_request(:get, "https://api.stripe.com/v1/prices").
            with(headers: { 'Authorization'=>'Bearer XYZ',}).
            to_return(status: 200, body: load_request_fixture('stripe_prices.json'))
        end

        it 'creates the price online' do
          Stripe::Price.expects(:create).with(
            :lookup_key => 'gold',
            :nickname => 'gold',
            :currency => 'usd',
            :product_data => {
              :name => 'Solid Gold',
              :statement_descriptor => nil
            },
            :unit_amount => 699,
            :recurring => {
              :interval => 'month'
            }
          )
          Stripe::Prices::GOLD.put!
        end

        it 'creates a price with an alternative currency' do
          Stripe::Price.expects(:create).with(
            :lookup_key => 'alternative_currency',
            :nickname => 'alternative_currency',
            :currency => 'cad',
            :product_data => {
              :name => 'Alternative Currency',
              :statement_descriptor => nil
            },
            :unit_amount => 699,
            :recurring => {
              :interval => 'month'
            }
          )
          Stripe::Prices::ALTERNATIVE_CURRENCY.put!
        end

        it 'creates a metered price' do
          Stripe::Price.expects(:create).with(
            :lookup_key => 'metered',
            :nickname => 'metered',
            :currency => 'usd',
            :product_data => {
              :name => 'Metered',
              :statement_descriptor => nil,
            },
            :unit_amount => 699,
            :recurring => {
              :interval => 'month',
              :usage_type => 'metered',
              :aggregate_usage => 'max',
            },
            :billing_scheme => 'per_unit'
          )
          Stripe::Prices::METERED.put!
        end

        it 'creates a tiered price' do
          Stripe::Price.expects(:create).with(
            :lookup_key => 'tiered',
            :nickname => 'tiered',
            :currency => 'usd',
            :product_data => {
              :name => 'Tiered',
              :statement_descriptor => nil,
            },
            :recurring => {
              :interval => 'month',
              :interval_count => 2,
              :usage_type => 'metered',
              :aggregate_usage => 'max'
            },
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
          Stripe::Prices::TIERED.put!
        end

        describe 'when passed invalid arguments for tiered pricing' do
          it 'raises a Stripe::InvalidConfigurationError when billing tiers are invalid' do
            lambda {
              Stripe.price "Bad Tiers".to_sym do |price|
                price.name = 'Acme as a service BAD TIERS'
                price.constant_name = 'BAD_TIERS'
                price.recurring = {
                  interval: 'month',
                  interval_count: 1,
                  usage_type: 'metered',
                  aggregate_usage: 'sum'
                }
                price.tiers_mode = 'graduated'
                price.billing_scheme = 'per_unit'
                price.tiers = [
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
              Stripe.price "Bad Tiers".to_sym do |price|
                price.name = 'Acme as a service BAD TIERS'
                price.constant_name = 'BAD_TIERS'
                price.recurring = {
                  interval: 'month',
                  interval_count: 1,
                  usage_type: 'metered',
                  aggregate_usage: 'sum'
                }
                price.tiers_mode = 'graduated'
                price.billing_scheme = 'per_unit'
                price.tiers = {
                  unit_amount: 1500,
                  up_to: 10
                }
              end
            }.must_raise Stripe::InvalidConfigurationError
          end
        end

        describe 'when using a product id' do
          before do
            Stripe::Prices::GOLD.product_id = 'prod_XXXXXXXXXXXXXX'
            Stripe::Prices::GOLD.name = nil
          end
          after do
            Stripe::Prices::GOLD.product_id = nil
            Stripe::Prices::GOLD.name = 'Solid Gold'
          end

          it 'creates the price online with the product id' do
            Stripe::Price.expects(:create).with(
              :lookup_key => 'gold',
              :nickname => 'gold',
              :currency => 'usd',
              :product => 'prod_XXXXXXXXXXXXXX',
              :unit_amount => 699,
              :recurring => {
                :interval => 'month'
              }
            )
            Stripe::Prices::GOLD.put!
          end
        end
      end

      describe 'when it is already present on stripe.com' do
        before do
          Stripe::Prices::GOLD.product_id = nil
          Stripe::Price.stubs(:list).returns(Stripe::Price.construct_from(
            data: [{
              :lookup_key => 'gold',
              :product => 'prod_XXXXXXXXXXXXXX'
          }]))
        end
        after do
          Stripe::Prices::GOLD.product_id = nil
        end


        it 'is a no-op on put!' do
          Stripe::Price.expects(:create).never
          Stripe::Prices::GOLD.put!
        end

        it 'transfers lookup key on reset!' do
          Stripe::Price.expects(:create).with(
            :lookup_key => 'gold',
            :transfer_lookup_key => true,
            :nickname => 'gold',
            :currency => 'usd',
            :product => 'prod_XXXXXXXXXXXXXX',
            :unit_amount => 699,
            :recurring => {
              :interval => 'month'
            }
          )

          Stripe::Prices::GOLD.reset!
        end
      end
    end
  end

  describe 'with missing mandatory values' do
    it 'raises an exception after configuring it' do
      _(-> { Stripe.price(:bad) {} }).must_raise Stripe::InvalidConfigurationError
    end
  end

  describe 'with custom constant name' do
    before do
      Stripe.price "Lite price".to_sym do |price|
        price.name = 'Acme as a service LITE'
        price.constant_name = 'LITE_PRICE'
        price.unit_amount = 699
        price.recurring = {
          interval: 'month',
          interval_count: 3,
          usage_type: 'metered',
          aggregate_usage: 'sum'
        }
        price.metadata = {:number_of_awesome_things => 5}
        price.statement_descriptor = 'Acme Lite'
        price.active = true
        price.nickname = 'lite'
        price.billing_scheme = 'per_unit'
        price.tiers_mode = 'graduated'
      end
    end

    after { Stripe::Prices.send(:remove_const, :LITE_PRICE) }

    it 'is accessible via upcased constant_name' do
      _(Stripe::Prices::LITE_PRICE).wont_be_nil
    end

    it 'is accessible via collection' do
      _(Stripe::Prices.all).must_include Stripe::Prices::LITE_PRICE
    end

    it 'is accessible via hash lookup (symbol/string agnostic)' do
      _(Stripe::Prices[:lite_price]).must_equal Stripe::Prices::LITE_PRICE
      _(Stripe::Prices['lite_price']).must_equal Stripe::Prices::LITE_PRICE
    end

    describe 'constant name validation' do
      it 'should be invalid when providing a constant name that can not be used for Ruby constant' do
        _(lambda {
          Stripe.price "Lite price".to_sym do |price|
            price.name = 'Acme as a service LITE'
            price.constant_name = 'LITE PRICE'
            price.unit_amount = 999
            price.recurring = {
              interval: 'month'
            }
          end
        }).must_raise Stripe::InvalidConfigurationError
      end
    end

    describe 'uploading' do
      include FixtureLoader

      describe 'when none exists on stripe.com' do
        before do
          Stripe::Price.stubs(:list).returns(Stripe::Price.construct_from(data: []))

          stub_request(:get, "https://api.stripe.com/v1/prices").
            with(headers: { 'Authorization'=>'Bearer XYZ',}).
            to_return(status: 200, body: load_request_fixture('stripe_prices.json'))
        end

        it 'creates the price online' do
          Stripe::Price.expects(:create).with(
            :lookup_key => "Solid Gold",
            :nickname => "Solid Gold",
            :currency => 'usd',
            :product_data => {
              :name => 'Solid Gold',
              :statement_descriptor => nil
            },
            :unit_amount => 699,
            :recurring => {
              :interval => 'month'
            }
          )
          Stripe::Prices::SOLID_GOLD.put!
        end
      end
    end
  end
end
