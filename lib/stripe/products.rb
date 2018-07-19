module Stripe
  module Products
    include ConfigurationBuilder

    configuration_for :product do
      attr_accessor :name,
                    :type

      validates_presence_of :name, :type

      validates_inclusion_of  :type,
                              in: %w(service good),
                              message: "'%{value}' is not 'service' or 'good'"

      private
      def create_options
        {
          name: name,
          type: type,
        }
      end
    end
  end
end
