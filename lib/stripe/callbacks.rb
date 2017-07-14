require 'stripe/callbacks/builder'

module Stripe
  module Callbacks
    include Callbacks::Builder

    callback 'account.updated'
    callback 'account.application.deauthorized'
    callback 'account.external_account.created'
    callback 'account.external_account.deleted'
    callback 'account.external_account.updated'
    callback 'application_fee.created'
    callback 'application_fee.refunded'
    callback 'application_fee.refund.updated'
    callback 'balance.available'
    callback 'bitcoin.receiver.created'
    callback 'bitcoin.receiver.filled'
    callback 'bitcoin.receiver.updated'
    callback 'bitcoin.receiver.transaction.created'
    callback 'charge.captured'
    callback 'charge.failed'
    callback 'charge.pending'
    callback 'charge.refunded'
    callback 'charge.succeeded'
    callback 'charge.updated'
    callback 'charge.dispute.closed'
    callback 'charge.dispute.created'
    callback 'charge.dispute.funds_reinstated'
    callback 'charge.dispute.funds_withdrawn'
    callback 'charge.dispute.updated'
    callback 'coupon.created'
    callback 'coupon.deleted'
    callback 'coupon.updated'
    callback 'customer.created'
    callback 'customer.deleted'
    callback 'customer.updated'
    callback 'customer.discount.created'
    callback 'customer.discount.deleted'
    callback 'customer.discount.updated'
    callback 'customer.source.created'
    callback 'customer.source.deleted'
    callback 'customer.source.updated'
    callback 'customer.subscription.created'
    callback 'customer.subscription.deleted'
    callback 'customer.subscription.trial_will_end'
    callback 'customer.subscription.updated'
    callback 'invoice.created'
    callback 'invoice.payment_failed'
    callback 'invoice.payment_succeeded'
    callback 'invoice.updated'
    callback 'invoiceitem.created'
    callback 'invoiceitem.deleted'
    callback 'invoiceitem.updated'
    callback 'order.created'
    callback 'order.payment_failed'
    callback 'order.payment_succeeded'
    callback 'order.updated'
    callback 'order_return.created'
    callback 'plan.created'
    callback 'plan.deleted'
    callback 'plan.updated'
    callback 'product.created'
    callback 'product.deleted'
    callback 'product.updated'
    callback 'recipient.created'
    callback 'recipient.deleted'
    callback 'recipient.updated'
    callback 'sku.created'
    callback 'sku.deleted'
    callback 'sku.updated'
    callback 'source.canceled'
    callback 'source.chargeable'
    callback 'source.failed'
    callback 'transfer.created'
    callback 'transfer.failed'
    callback 'transfer.paid'
    callback 'transfer.reversed'
    callback 'transfer.updated'
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
