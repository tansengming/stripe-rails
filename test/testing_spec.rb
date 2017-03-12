require 'minitest/autorun'
require 'spec_helper'

describe "Testing" do
  code = nil

  before do
    StripeMock.start

    @observer = Class.new.tap do |cls|
      cls.class_eval do
        include Stripe::Callbacks
      end
    end

    code = proc {|target, e| @event = e; @target = target}
    @observer.class_eval do
      after_invoice_payment_succeeded! do |evt, target|
        code.call(evt, target)
      end
    end
  end
  
  after do
    ::Stripe::Callbacks.clear_callbacks!
    StripeMock.stop
  end

  it "exposes a send_event method" do
    (defined? Stripe::Testing.send_event).must_equal 'method'
  end

  it "forward the event to the registered callbacks" do
    Stripe::Testing.send_event "invoice.payment_succeeded"
    @event.wont_be_nil
    @event.type.must_equal "invoice.payment_succeeded"
  end

  it "doesn't forward the event to the other callbacks" do
    Stripe::Testing.send_event "customer.created"
    @event.must_be_nil
  end

  it "overwrites event properties" do
    Stripe::Testing.send_event "invoice.payment_succeeded", {
      :subtotal => 500,
      :total => 1000,
      :currency => "eur"
    }

    @event.wont_be_nil
    @event.type.must_equal "invoice.payment_succeeded"
    @target.subtotal.must_equal 500
    @target.total.must_equal 1000
    @target.currency.must_equal "eur"
  end
end
