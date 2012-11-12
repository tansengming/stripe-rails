require 'minitest/autorun'
require 'spec_helper'

describe 'building plans' do
  describe 'simply' do
    before do
      Stripe.plan :primo do |plan|
        plan.name = 'Acme as a service PRIMO'
        plan.amount = 699
        plan.interval = 'monthly'
        plan.interval_count = 3
        plan.trial_period_days = 30
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
  end

  describe 'with missing mandatory values' do
    it 'raises an exception after configuring it' do
      proc {Stripe.plan(:bad) {}}.must_raise Stripe::Plans::InvalidPlanError
    end
  end
end
