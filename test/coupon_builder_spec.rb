require 'minitest/autorun'
require 'spec_helper'

describe 'building plans' do
  describe 'simply' do
    before do
      @now = Time.now.utc
      Stripe.coupon(:gold25) do |coupon|
        coupon.duration = 'repeating'
        coupon.duration_in_months = 10
        coupon.amount_off = 100
        coupon.currency = 'USD'
        coupon.max_redemptions = 3
        coupon.percent_off = 25
        coupon.redeem_by = @now
      end
    end
    after {Stripe::Coupons.send(:remove_const, :GOLD25)}

    it 'is accessible via hash lookup (symbol/string agnostic)' do
      Stripe::Coupons[:gold25].must_equal Stripe::Coupons::GOLD25
      Stripe::Coupons['gold25'].must_equal Stripe::Coupons::GOLD25
    end

    describe 'uploading' do
      describe 'when none exists on stripe.com' do
        before do
          Stripe::Coupon.stubs(:retrieve).raises(Stripe::InvalidRequestError.new("not found", "id"))
        end
        it 'creates the plan online' do
          Stripe::Coupon.expects(:create).with(
            :id => :gold25,
            :duration => 'repeating',
            :duration_in_months => 10,
            :amount_off => 100,
            :currency => 'USD',
            :max_redemptions => 3,
            :percent_off => 25,
            :redeem_by => @now
          )
          Stripe::Coupons.put!
        end

      end
      describe 'when it is already present on stripe.com' do
        before do
          Stripe::Coupon.stubs(:retrieve).returns(Stripe::Coupon.construct_from({
            :id => :gold25,
          }))
        end
        it 'is a no-op' do
          Stripe::Coupon.expects(:create).never
          Stripe::Coupons.put!
        end
      end
    end
  end

  describe 'with missing mandatory values' do
    it 'raises an exception after configuring it' do
      proc {Stripe.coupon(:bad) {}}.must_raise Stripe::InvalidConfigurationError
    end
  end
end
