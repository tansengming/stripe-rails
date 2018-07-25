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
          active: active,
          attributes: attributes,
          description: description,
          caption: caption,
          metadata: metadata,
          shippable: shippable,
          url: url,
        }.delete_if{|_, v| v.nil? }
      end
    end
  end
end
