require 'minitest/autorun'
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
      end
    end
    after do
      Stripe::Plans.send(:remove_const, :PRIMO)
    end

    it 'is accessible via id' do
      Stripe::Plans::PRIMO.wont_be_nil
    end

    it 'is accessible via collection' do
      Stripe::Plans.all.must_include Stripe::Plans::PRIMO
    end

    it 'is accessible via hash lookup (symbol/string agnostic)' do
      Stripe::Plans[:primo].must_equal Stripe::Plans::PRIMO
      Stripe::Plans['primo'].must_equal Stripe::Plans::PRIMO
    end

    it 'accepts a billing interval of a week' do
      Stripe.plan :weekly do |plan|
        plan.name = 'Acme as a service weekly'
        plan.amount = 100
        plan.interval = 'week'
      end

      Stripe::Plans::WEEKLY.wont_be_nil
    end

    it 'accepts a billing interval of a month' do
      Stripe.plan :monthly do |plan|
        plan.name = 'Acme as a service monthly'
        plan.amount = 400
        plan.interval = 'month'
      end

      Stripe::Plans::MONTHLY.wont_be_nil
    end

    it 'accepts a billing interval of a year' do
      Stripe.plan :yearly do |plan|
        plan.name = 'Acme as a service yearly'
        plan.amount = 4800
        plan.interval = 'year'
      end

      Stripe::Plans::YEARLY.wont_be_nil
    end

    it 'denies arbitrary billing intervals' do
      lambda {
        Stripe.plan :broken do |plan|
          plan.name = 'Acme as a service BROKEN'
          plan.amount = 999
          plan.interval = 'anything'
        end
      }.must_raise Stripe::InvalidConfigurationError
    end

    describe 'uploading' do
      describe 'when none exists on stripe.com' do
        before do
          Stripe::Plan.stubs(:retrieve).raises(Stripe::InvalidRequestError.new("not found", "id"))
        end

        it 'creates the plan online' do
          Stripe::Plan.expects(:create).with(
            :id => :gold,
            :currency => 'usd',
            :name => 'Solid Gold',
            :amount => 699,
            :interval => 'month',
            :interval_count => 1,
            :trial_period_days => 0,
            :metadata => nil
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
            :trial_period_days => 0,
            :metadata => nil
          )
          Stripe::Plans::ALTERNATIVE_CURRENCY.put!
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
      proc {Stripe.plan(:bad) {}}.must_raise Stripe::InvalidConfigurationError
    end
  end
end
