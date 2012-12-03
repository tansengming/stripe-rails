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

    def self.put!
      all.each do |plan|
        plan.put!
      end
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
      validates_inclusion_of :interval, :in => %w(month year), :message => "'%{value}' is not one of 'month' or 'year'"

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

      def put!
        if exists?
          puts "[EXISTS] - #{@id}" unless Stripe::Engine.testing
        else
          plan = Stripe::Plan.create(
            :id => @id,
            :currency => @currency,
            :name => @name,
            :amount => @amount,
            :interval => @interval,
            :interval_count => @interval_count,
            :trial_period_days => @trial_period_days
          )
          puts "[CREATE] - #{plan}" unless Stripe::Engine.testing
        end
      end

      def to_s
        @id.to_s
      end

      def exists?
        !!Stripe::Plan.retrieve("#{@id}")
      rescue Stripe::InvalidRequestError
        false
      end
    end

    class InvalidPlanError < StandardError
      attr_reader :errors

      def initialize(errors)
        super errors.messages
        @errors = errors
      end

    end

  end
  extend Plans
end