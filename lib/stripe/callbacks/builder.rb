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
            self::ClassMethods.send(:define_method, method_name) do |&block|
              ::Stripe::Callbacks::noncritical_callbacks[name] << block
            end
            self::ClassMethods.send(:define_method, "#{method_name}!") do |&block|
              ::Stripe::Callbacks::critical_callbacks[name] << block
            end
          end
        end
      end
    end
  end
end