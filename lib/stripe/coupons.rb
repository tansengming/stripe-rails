module Stripe
  module Coupons
    include ConfigurationBuilder

    configuration_for :coupon do
      attr_accessor :name, :duration, :amount_off, :currency, :duration_in_months, :max_redemptions, :percent_off, :redeem_by

      validates_presence_of :id, :duration
      validates_presence_of :duration_in_months, :if => :repeating?
      validates_inclusion_of :duration, :in => %w(forever once repeating), :message => "'%{value}' is not one of 'forever', 'once' or 'repeating'"
      validates_inclusion_of :percent_off, in: 1..100, unless: ->(coupon) {coupon.percent_off.nil?}
      validates_numericality_of :percent_off, :greater_than => 0, unless: ->(coupon) {coupon.percent_off.nil?}
      validates_numericality_of :duration_in_months, :greater_than => 0, :if => :repeating?
      validates_numericality_of :max_redemptions, greater_than: 0, unless: ->(coupon) {coupon.max_redemptions.nil?}

      def initialize(*args)
        super
        @currency = 'usd'
        @max_redemptions = 1
      end

      def repeating?
        duration == 'repeating'
      end

      def create_options
        {
          :name => name,
          :duration => duration,
          :percent_off => percent_off,
          :amount_off => amount_off,
          :currency => currency,
          :duration_in_months => duration_in_months,
          :max_redemptions => max_redemptions,
          :redeem_by => redeem_by
        }
      end
    end
  end
end
