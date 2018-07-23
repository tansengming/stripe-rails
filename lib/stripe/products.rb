module Stripe
  module Products
    include ConfigurationBuilder

    configuration_for :product do
      attr_accessor :name,
                    :type,
                    :active,
                    :attributes,
                    :description,
                    :caption,
                    :metadata,
                    :shippable,
                    :url

      validates_presence_of :name, :type

      validates :active, :shippable, inclusion: { in: [true, false] }, allow_nil: true
      validates :type, inclusion: { in: %w(service good) }
      validates :caption, :description, :shippable, :url, absence: true, unless: :good?

      private
      def good?
        type == 'good'
      end

      def create_options
        {
          name: name,
          type: type,
        }
      end
    end
  end
end
