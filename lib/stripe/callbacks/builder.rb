module Stripe
  module Callbacks
    module Builder
      extend ActiveSupport::Concern

      included do
        extend ActiveSupport::Concern
        @critical_callbacks = Hash.new do |h, k|
          h[k] = []
        end
        @noncritical_callbacks = Hash.new do |h, k|
          h[k] = []
        end
        module ClassMethods
        end

        class << self
          attr_reader :critical_callbacks, :noncritical_callbacks

          def clear_callbacks!
            critical_callbacks.clear
            noncritical_callbacks.clear
          end

          def callback(name)
            method_name = "after_#{name.gsub('.', '_')}"

            self::ClassMethods.send(:define_method, method_name) do |options = {}, &block|
              ::Stripe::Callbacks::noncritical_callbacks[name] << ::Stripe::Callbacks.callback_matcher(options, block)
            end
            self::ClassMethods.send(:define_method, "#{method_name}!") do |options = {}, &block|
              ::Stripe::Callbacks::critical_callbacks[name] << ::Stripe::Callbacks.callback_matcher(options, block)
            end
          end

          def callback_matcher(options, block)
            case only = options[:only]
            when Proc, Method
              proc do |target, evt|
                block.call(target, evt) if only.call(target, evt)
              end
            when Array, Set
              stringified_keys = only.map(&:to_s)
              proc do |target, evt|
                stringified_previous_attributes_keys = evt.data.previous_attributes.keys.map(&:to_s)
                intersection =  stringified_previous_attributes_keys - stringified_keys
                block.call(target, evt) if intersection != stringified_previous_attributes_keys
              end
            when nil
              block
            else
              callback_matcher options.merge(:only => [only]), block
            end
          end
        end
      end
    end
  end
end