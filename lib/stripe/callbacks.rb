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
    callback 'charge.refund.updated'
    callback 'checkout.session.completed'
    callback 'checkout.session.expired'
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
    callback 'customer.source.expiring'
    callback 'customer.source.updated'
    callback 'customer.subscription.created'
    callback 'customer.subscription.deleted'
    callback 'customer.subscription.trial_will_end'
    callback 'customer.subscription.updated'
    callback 'file.created'
    callback 'invoice.created'
    callback 'invoice.finalized'
    callback 'invoice.marked_uncollectible'
    callback 'invoice.paid'
    callback 'invoice.payment_action_required'
    callback 'invoice.payment_failed'
    callback 'invoice.payment_succeeded'
    callback 'invoice.sent'
    callback 'invoice.upcoming'
    callback 'invoice.updated'
    callback 'invoice.voided'
    callback 'invoiceitem.created'
    callback 'invoiceitem.deleted'
    callback 'invoiceitem.updated'
    callback 'order.created'
    callback 'order.payment_failed'
    callback 'order.payment_succeeded'
    callback 'order.updated'
    callback 'order_return.created'
    callback 'payment_intent.amount_capturable_updated'
    callback 'payment_intent.canceled'
    callback 'payment_intent.created'
    callback 'payment_intent.payment_failed'
    callback 'payment_intent.processing'
    callback 'payment_intent.requires_action'
    callback 'payment_intent.succeeded'
    callback 'payment_method.attached'
    callback 'payment_method.card_automatically_updated'
    callback 'payment_method.detached'
    callback 'payment_method.updated'
    callback 'payout.canceled'
    callback 'payout.created'
    callback 'payout.failed'
    callback 'payout.paid'
    callback 'payout.updated'
    callback 'plan.created'
    callback 'plan.deleted'
    callback 'plan.updated'
    callback 'price.created'
    callback 'price.deleted'
    callback 'price.updated'
    callback 'product.created'
    callback 'product.deleted'
    callback 'product.updated'
    callback 'recipient.created'
    callback 'recipient.deleted'
    callback 'recipient.updated'
    callback 'review.closed'
    callback 'review.opened'
    callback 'setup_intent.canceled'
    callback 'setup_intent.created'
    callback 'setup_intent.requires_action'
    callback 'setup_intent.setup_failed'
    callback 'setup_intent.succeeded'
    callback 'sigma.scheduled_query_run.created'
    callback 'sku.created'
    callback 'sku.deleted'
    callback 'sku.updated'
    callback 'source.canceled'
    callback 'source.chargeable'
    callback 'source.failed'
    callback 'source.transaction.created'
    callback 'subscription_schedule.aborted'
    callback 'subscription_schedule.canceled'
    callback 'subscription_schedule.completed'
    callback 'subscription_schedule.created'
    callback 'subscription_schedule.expiring'
    callback 'subscription_schedule.released'
    callback 'subscription_schedule.updated'
    callback 'tax_rate.created'
    callback 'tax_rate.updated'
    callback 'transfer.created'
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
