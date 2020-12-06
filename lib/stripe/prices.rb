module Stripe
  module Prices
    include ConfigurationBuilder
    VALID_TIME_UNITS = %i(day week month year)

    configuration_for :price do
      attr_reader   :lookup_key
      attr_accessor :active,
                    :billing_scheme,
                    :constant_name,
                    :currency,
                    :metadata,
                    :name,
                    :nickname,
                    :object,
                    :product_id,
                    :recurring,
                    :statement_descriptor,
                    :tiers,
                    :tiers_mode,
                    :transform_quantity,
                    :type,
                    :unit_amount

      validates_presence_of :id, :currency
      validates_presence_of :unit_amount, unless: ->(p) { p.billing_scheme == 'tiered' }
      validates_absence_of :transform_quantity, if: ->(p) { p.billing_scheme == 'tiered' }
      validates_presence_of :tiers_mode, :tiers, if: ->(p) { p.billing_scheme == 'tiered' }

      validates_numericality_of :recurring_interval_count, allow_nil: true

      validates_inclusion_of  :recurring_interval,
                              in: VALID_TIME_UNITS.collect(&:to_s),
                              message: "'%{value}' is not one of #{VALID_TIME_UNITS.to_sentence(last_word_connector: ', or ')}",
                              if: ->(p) { p.recurring.present? }

      validates :statement_descriptor, length: { maximum: 22 }

      validates :active,                    inclusion: { in: [true, false] }, allow_nil: true
      validates :billing_scheme,            inclusion: { in: %w{ per_unit tiered } }, allow_nil: true
      validates :recurring_aggregate_usage, inclusion: { in: %w{ sum last_during_period last_ever max } }, allow_nil: true
      validates :recurring_usage_type,      inclusion: { in: %w{ metered licensed } }, allow_nil: true
      validates :tiers_mode,                inclusion: { in: %w{ graduated volume } }, allow_nil: true

      validate :name_or_product_id
      validate :recurring_aggregate_usage_must_be_metered, if: ->(p) { p.recurring_aggregate_usage.present? }
      validate :recurring_interval_count_maximum, if: ->(p) { p.recurring_interval_count.present? }
      validate :valid_constant_name, unless: ->(p) { p.constant_name.nil? }

      # validations for when using tiered billing
      validate :tiers_must_be_array, if: ->(p) { p.tiers.present? }
      validate :billing_scheme_must_be_tiered, if: ->(p) { p.tiers.present? }
      validate :validate_tiers, if: ->(p) { p.billing_scheme == 'tiered' }

      def initialize(*args)
        super(*args)
        @currency = 'usd'
        @lookup_key = @id.to_s
        @recurring = (recurring || {}).symbolize_keys
      end

      # We're overriding a handful of the Configuration methods so that
      # we find and create by lookup_key instead of by ID.  The ID is assigned
      # by stripe and out of our control
      def put!
        if exists?
          puts "[EXISTS] - #{@stripe_class}:#{@id}:#{stripe_id}" unless Stripe::Engine.testing
        else
          object = @stripe_class.create({:lookup_key => @lookup_key}.merge compact_create_options)
          puts "[CREATE] - #{@stripe_class}:#{object}" unless Stripe::Engine.testing
        end
      end

      # You can't delete prices, but you can transfer the lookup key to a new price
      def reset!
        object = @stripe_class.create(reset_options)
        puts "[RESET] - #{@stripe_class}:#{object}" unless Stripe::Engine.testing
      end

      def exists?
        stripe_object.presence
      rescue Stripe::InvalidRequestError
        false
      end

      def stripe_object
        @stripe_class.list({lookup_keys: [@lookup_key]}).data.first.presence || nil
      rescue Stripe::InvalidRequestError
        nil
      end

      def stripe_id
        @stripe_id ||= stripe_object.try(:id)
      end

      def recurring_interval
        recurring[:interval]
      end

      def recurring_aggregate_usage
        recurring[:aggregate_usage]
      end

      def recurring_usage_type
        recurring[:usage_type]
      end

      def recurring_interval_count
        recurring[:interval_count]
      end

      private
      def recurring_aggregate_usage_must_be_metered
        errors.add(:recurring_aggregate_usage, 'recurring[:usage_type] must be metered') unless (recurring_usage_type == 'metered')
      end

      def recurring_interval_count_maximum
        time_unit = recurring_interval.to_sym

        return unless VALID_TIME_UNITS.include?(time_unit) && recurring_interval_count.respond_to?(time_unit)
        too_long = recurring_interval_count.send(time_unit) > 1.year

        errors.add(:recurring_interval_count, 'recurring[:interval_count] Maximum is one year (1 year, 12 months, or 52 weeks') if too_long
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

      def reset_options
        existing_object = stripe_object
        # Lookup and set the existing product ID if unset
        @product_id ||= existing_object.product if existing_object.present?

        { transfer_lookup_key: existing_object.present? }.merge(compact_create_options)
      end

      def create_options
        {
          currency: currency,
          unit_amount: unit_amount,
          active: active,
          metadata: metadata,
          nickname: nickname.presence || @lookup_key,
          recurring: recurring.compact,
          tiers: tiers ? tiers.map(&:to_h) : nil,
          tiers_mode: tiers_mode,
          billing_scheme: billing_scheme,
          lookup_key: @lookup_key,
          transform_quantity: transform_quantity,
        }.merge(product_options).compact
      end

      def product_options
        if product_id.present?
          { product: product_id }
        else
          {
            product_data: { name: name, statement_descriptor: statement_descriptor }
          }
        end
      end
    end
  end
end
