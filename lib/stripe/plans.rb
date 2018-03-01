module Stripe
  module Plans
    include ConfigurationBuilder

    configuration_for :plan do
      attr_accessor :name, :amount, :interval, :interval_count, :trial_period_days,
                    :currency, :metadata, :statement_descriptor

      validates_presence_of :id, :amount, :currency, :name

      validates_inclusion_of :interval, :in => %w(day week month year),
        :message => "'%{value}' is not one of 'day', 'week', 'month' or 'year'"

      validates :statement_descriptor, :length => { :maximum => 22 }

      def initialize(*args)
        super(*args)
        @currency = 'usd'
        @interval_count = 1
        @trial_period_days = 0
      end

      def create_options
        change_time = Time.parse '2018-02-05'

        if Stripe.api_version && Time.parse(Stripe.api_version) >= change_time
          post_change_create_options
        else
          pre_change_create_options
        end
      end

      def post_change_create_options
        {
          :currency => @currency,
          product: {
            :name => @name,
          },
          :amount => @amount,
          :interval => @interval,
          :interval_count => @interval_count,
          :trial_period_days => @trial_period_days,
          :metadata => @metadata,
          :statement_descriptor => @statement_descriptor
        }
      end

      def pre_change_create_options
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
