require 'stripe/callbacks/builder'

module Stripe
  module Callbacks
    include Callbacks::Builder

    callback 'account.updated'
    callback 'account.application.deauthorized'
    callback 'charge.succeeded'
    callback 'charge.failed'
    callback 'charge.refunded'
    callback 'charge.dispute.created'
    callback 'charge.dispute.updated'
    callback 'charge.dispute.closed'
    callback 'customer.created'
    callback 'customer.updated'
    callback 'customer.deleted'
    callback 'customer.subscription.created'
    callback 'customer.subscription.updated'
    callback 'customer.subscription.deleted'
    callback 'customer.subscription.trial_will_end'
    callback 'customer.discount.created'
    callback 'customer.discount.updated'
    callback 'customer.discount.deleted'
    callback 'invoice.created'
    callback 'invoice.updated'
    callback 'invoice.payment_succeeded'
    callback 'invoice.payment_failed'
    callback 'invoiceitem.created'
    callback 'invoiceitem.updated'
    callback 'invoiceitem.deleted'
    callback 'plan.created'
    callback 'plan.updated'
    callback 'plan.deleted'
    callback 'coupon.created'
    callback 'coupon.updated'
    callback 'coupon.deleted'
    callback 'transfer.created'
    callback 'transfer.updated'
    callback 'transfer.failed'
    callback 'ping'

    class << self
      def run_callbacks(evt)
        run_critical_callbacks evt
        run_noncritical_callbacks evt
      end

      def run_critical_callbacks(evt)
        ::Stripe::Callbacks::critical_callbacks[evt.type].each do |callback|
          callback.call(evt)
        end
      end

      def run_noncritical_callbacks(evt)
        ::Stripe::Callbacks::noncritical_callbacks[evt.type].each do |callback|
          begin
            callback.call(evt)
          rescue Exception => e
            ::Rails.logger.error e.message
            ::Rails.logger.error e.backtrace.join("\n")
          end
        end
      end
    end
  end
end