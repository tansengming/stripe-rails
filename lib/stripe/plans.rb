module Stripe
  module Plans
    include ConfigurationBuilder

    configuration_for :plan do
      attr_accessor :active,
                    :amount,
                    :currency,
                    :interval,
                    :interval_count,
                    :metadata,
                    :name, 
                    :product_id,
                    :statement_descriptor,
                    :trial_period_days

      validates_presence_of :id, :amount, :currency

      validates_inclusion_of  :interval,
                              :in => %w(day week month year),
                              :message => "'%{value}' is not one of 'day', 'week', 'month' or 'year'"

      validates :statement_descriptor, :length => { :maximum => 22 }
      validates :active, inclusion: { in: [true, false] }, allow_nil: true

      validate :name_or_product_id

      def initialize(*args)
        super(*args)
        @currency = 'usd'
        @interval_count = 1
        @trial_period_days = 0
      end

      private
      def name_or_product_id
        errors.add(:base, 'must have a product_id or a name') unless (@product_id.present? ^ @name.present?)
      end

      def create_options
        if CurrentApiVersion.after_switch_to_products_in_plans?
          default_create_options
        else
          create_options_without_products
        end
      end

      def default_create_options
        {
          :currency => @currency,
          product: product_options,
          :amount => @amount,
          :interval => @interval,
          :interval_count => @interval_count,
          :trial_period_days => @trial_period_days,
          :metadata => @metadata,
        }
      end

      def product_options
        @product_id.presence || { :name => @name, :statement_descriptor => @statement_descriptor }
      end

      def create_options_without_products
        {
          :currency => @currency,
          :name => @name,
          :amount => @amount,
          :interval => @interval,
          :interval_count => @interval_count,
          :trial_period_days => @trial_period_days,
          :metadata => @metadata,
          :statement_descriptor => @statement_descriptor
        }
      end
    end
  end
end
