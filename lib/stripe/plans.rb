module Stripe
  module Plans
    include ConfigurationBuilder

    configuration_for :plan do
      attr_accessor :name, 
                    :amount,
                    :interval,
                    :interval_count,
                    :trial_period_days,
                    :currency,
                    :metadata,
                    :statement_descriptor

      validates_presence_of :id, :amount, :currency, :name

      validates_inclusion_of  :interval,
                              :in => %w(day week month year),
                              :message => "'%{value}' is not one of 'day', 'week', 'month' or 'year'"

      validates :statement_descriptor, :length => { :maximum => 22 }

      def initialize(*args)
        super(*args)
        @currency = 'usd'
        @interval_count = 1
        @trial_period_days = 0
      end

      private

      def create_options
        if api_version_after_switch_to_products_in_plans
          default_create_options
        else
          create_options_without_products
        end
      end

      def api_version_after_switch_to_products_in_plans
        Date.parse(current_api_version) >= Date.parse('2018-02-05')
      end

      def current_api_version
        Stripe.api_version || begin
          resp, _ = @stripe_class.request(:get, @stripe_class.resource_url)
          resp.http_headers['stripe-version']
        end
      end

      def default_create_options
        {
          :currency => @currency,
          product: {
            :name => @name,
            :statement_descriptor => @statement_descriptor,
          },
          :amount => @amount,
          :interval => @interval,
          :interval_count => @interval_count,
          :trial_period_days => @trial_period_days,
          :metadata => @metadata,
        }
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
