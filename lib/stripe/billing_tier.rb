module Stripe
  module Plans
    class BillingTier
      include ActiveModel::Validations

      validates_presence_of :up_to
      validates_presence_of :flat_amount, if: ->(tier) { tier.unit_amount.nil? },
        message: 'one of `flat_amount` or `unit_amount` must be specified!'
      validates_presence_of :unit_amount, if: ->(tier) { tier.flat_amount.nil? },
        message: 'one of `flat_amount` or `unit_amount` must be specified!'
      validates_absence_of :flat_amount, if: ->(tier) { tier.unit_amount.present? },
        message: 'only one of `flat_amount` or `unit_amount` should be specified!'
      validates_absence_of :unit_amount, if: ->(tier) { tier.flat_amount.present? },
        message: 'only one of `flat_amount` or `unit_amount` should be specified!'

      attr_accessor :up_to, :flat_amount, :unit_amount

      def initialize(attrs)
        @up_to = attrs[:up_to]
        @flat_amount = attrs[:flat_amount]
        @unit_amount = attrs[:unit_amount]
      end

      def to_h
        {
          up_to: up_to,
          flat_amount: flat_amount,
          unit_amount: unit_amount
        }.compact
      end

    end
  end
end
