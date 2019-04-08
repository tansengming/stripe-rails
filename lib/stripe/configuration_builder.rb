require "active_model"

module Stripe
  module ConfigurationBuilder
    extend ActiveSupport::Concern

    included do
      class << self
        def configuration_for(class_id, &block)
          @_configuration_storage = "@#{class_id.to_s.pluralize}"
          instance_variable_set(@_configuration_storage, {})
          configuration_class = Class.new(Stripe::ConfigurationBuilder::Configuration)
          const_set(:Configuration, configuration_class)
          configuration_class.class_eval(&block)
          stripe_class = Stripe.const_get(class_id.to_s.camelize)
          stripe_configuration_class = self
          send(:define_method, class_id) do |id, &block|
            config = configuration_class.new(id, stripe_class, stripe_configuration_class)
            block.call config
            config.finalize!
          end
          ::Stripe.send(:extend, self)
        end

        def configurations
          instance_variable_get(@_configuration_storage)
        end

        def all
          configurations.values
        end

        def [](key)
          configurations[key.to_s]
        end

        def []=(key, value)
          configurations[key.to_s] = value
        end

        def put!
          all.each(&:put!)
        end

        def reset!
          all.each(&:reset!)
        end
      end
    end

    class Configuration
      include ActiveModel::Validations
      attr_reader :id

      def initialize(id, stripe_class, stripe_configuration_class)
        @id = id
        @stripe_class = stripe_class
        @stripe_configuration_class = stripe_configuration_class
      end

      def finalize!
        validate!
        globalize!
      end

      def validate!
        fail Stripe::InvalidConfigurationError, errors if invalid?
      end

      def globalize!
        id_to_use = @constant_name || @id
        @stripe_configuration_class[id_to_use.to_s.downcase] = self
        @stripe_configuration_class.const_set(id_to_use.to_s.upcase, self)
      end

      def put!
        if exists?
          puts "[EXISTS] - #{@stripe_class}:#{@id}" unless Stripe::Engine.testing
        else
          object = @stripe_class.create({:id => @id}.merge compact_create_options)
          puts "[CREATE] - #{@stripe_class}:#{object}" unless Stripe::Engine.testing
        end
      end

      def reset!
        if object = exists?
          object.delete
        end
        object = @stripe_class.create({:id => @id}.merge compact_create_options)
        puts "[RESET] - #{@stripe_class}:#{object}" unless Stripe::Engine.testing
      end

      def compact_create_options
        create_options.delete_if { |_, v| v.nil? }
      end

      def to_s
        @id.to_s
      end

      def exists?
        @stripe_class.retrieve(to_s)
      rescue Stripe::InvalidRequestError
        false
      end
    end
  end

  class InvalidConfigurationError < StandardError
    attr_reader :errors

    def initialize(errors)
      super errors.messages
      @errors = errors
    end

  end
end
