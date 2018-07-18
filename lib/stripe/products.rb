module Stripe
  module Products
    include ConfigurationBuilder

    configuration_for :product do
      attr_accessor :name,
                    :type

      validates_presence_of :name, :type

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
