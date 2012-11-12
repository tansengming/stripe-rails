module Stripe
  module Plans
    @plans = {}

    def self.all
      @plans.values
    end

    def self.[](key)
      @plans[key.to_s]
    end

    def self.[]=(key, value)
      @plans[key.to_s] = value
    end

    def plan(id)
      config = Configuration.new(id)
      yield config
      config.finalize!
    end

    class Configuration
      include ActiveModel::Validations
      attr_reader :id, :currency
      attr_accessor :name, :amount, :interval, :interval_count, :trial_period_days

      validates_presence_of :id, :name, :amount
      def initialize(id)
        @id = id
        @currency = 'usd'
        @interval_count = 1
        @trial_period_days = 0
      end

      def finalize!
        validate!
        globalize!
      end

      def validate!
        fail InvalidPlanError, errors if invalid?
      end

      def globalize!
        Stripe::Plans[@id.to_s] = self
        Stripe::Plans.const_set(@id.to_s.upcase, self)
      end
    end
    
    class InvalidPlanError < StandardError
      attr_reader :errors

      def initialize(errors)
        @errors = errors
      end

    end

  end
  extend Plans
end