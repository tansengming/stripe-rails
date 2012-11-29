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
    callback 'stripe.event'

    class << self
      def run_callbacks(evt, target)
        _run_callbacks evt.type, evt, target
        _run_callbacks 'stripe.event', evt, target
      end

      def _run_callbacks(type, evt, target)
        run_critical_callbacks type, evt, target
        run_noncritical_callbacks type, evt, target
      end

      def run_critical_callbacks(type, evt, target)
        ::Stripe::Callbacks::critical_callbacks[type].each do |callback|
          callback.call(target, evt)
        end
      end

      def run_noncritical_callbacks(type, evt, target)
        ::Stripe::Callbacks::noncritical_callbacks[type].each do |callback|
          begin
            callback.call(target, evt)
          rescue Exception => e
            ::Rails.logger.error e.message
            ::Rails.logger.error e.backtrace.join("\n")
          end
        end
      end
    end
  end
end