module Stripe
  module Products
    include ConfigurationBuilder

    configuration_for :product do
      attr_accessor :name,
                    :type

      validates_presence_of :name, :type
    end
  end
end
