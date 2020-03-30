module Stripe
  module Plans
    include ConfigurationBuilder

    configuration_for :plan do
      attr_accessor :active,
                    :aggregate_usage,
                    :amount,
                    :billing_scheme,
                    :constant_name,
                    :currency,
                    :interval,
                    :interval_count,
                    :metadata,
                    :name,
                    :nickname,
                    :product_id,
                    :statement_descriptor,
                    :tiers,
                    :tiers_mode,
                    :transform_usage,
                    :trial_period_days,
                    :usage_type

      validates_presence_of :id, :currency
      validates_presence_of :amount, unless: ->(p) { p.billing_scheme == 'tiered' }
      validates_absence_of :transform_usage, if: ->(p) { p.billing_scheme == 'tiered' }
      validates_presence_of :tiers_mode, if: ->(p) { p.billing_scheme == 'tiered' }
      validates_inclusion_of  :interval,
                              in: %w(day week month year),
                              message: "'%{value}' is not one of 'day', 'week', 'month' or 'year'"

      validates :statement_descriptor, length: { maximum: 22 }

      validates :active,          inclusion: { in: [true, false] }, allow_nil: true
      validates :usage_type,      inclusion: { in: %w{ metered licensed } }, allow_nil: true
      validates :billing_scheme,  inclusion: { in: %w{ per_unit tiered } }, allow_nil: true
      validates :aggregate_usage, inclusion: { in: %w{ sum last_during_period last_ever max } }, allow_nil: true
      validates :tiers_mode,      inclusion: { in: %w{ graduated volume } }, allow_nil: true

      validate :name_or_product_id
      validate :aggregate_usage_must_be_metered, if: ->(p) { p.aggregate_usage.present? }
      validate :valid_constant_name, unless: ->(p) { p.constant_name.nil? }

      # validations for when using tiered billing
      validate :tiers_must_be_array, if: ->(p) { p.tiers.present? }
      validate :billing_scheme_must_be_tiered, if: ->(p) { p.tiers.present? }
      validate :validate_tiers, if: ->(p) { p.billing_scheme == 'tiered' }

      def initialize(*args)
        super(*args)
        @currency = 'usd'
        @interval_count = 1
        @trial_period_days = 0
      end

      private
      def aggregate_usage_must_be_metered
        errors.add(:aggregate_usage, 'usage_type must be metered') unless (usage_type == 'metered')
      end

      def name_or_product_id
        errors.add(:base, 'must have a product_id or a name') unless (@product_id.present? ^ @name.present?)
      end

      def billing_scheme_must_be_tiered
        errors.add(:billing_scheme, 'must be set to `tiered` when specifying `tiers`') unless billing_scheme == 'tiered'
      end

      def tiers_must_be_array
        errors.add(:tiers, 'must be an Array') unless tiers.is_a?(Array)
      end

      def billing_tiers
        @billing_tiers = tiers.map { |t| Stripe::Plans::BillingTier.new(t) } if tiers
      end

      def validate_tiers
        billing_tiers.all?(&:valid?)
      end

      module ConstTester; end
      def valid_constant_name
        ConstTester.const_set(constant_name.to_s.upcase, constant_name)
        ConstTester.send(:remove_const, constant_name.to_s.upcase.to_sym)
      rescue NameError
        errors.add(:constant_name, 'is not a valid Ruby constant name.')
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
          currency: currency,
          product: product_options,
          amount: amount,
          interval: interval,
          interval_count: interval_count,
          trial_period_days: trial_period_days,
          metadata: metadata,
          usage_type: usage_type,
          aggregate_usage: aggregate_usage,
          billing_scheme: billing_scheme,
          nickname: nickname,
          tiers: tiers ? tiers.map(&:to_h) : nil,
          tiers_mode: tiers_mode,
          transform_usage: transform_usage
        }.compact
      end

      def product_options
        product_id.presence || { name: name, statement_descriptor: statement_descriptor }
      end

      # Note: these options serve an older API, as such they should
      # probably never be updated.
      def create_options_without_products
        {
          currency: currency,
          name: name,
          amount: amount,
          interval: interval,
          interval_count: interval_count,
          trial_period_days: trial_period_days,
          metadata: metadata,
          statement_descriptor: statement_descriptor
        }
      end
    end
  end
end
