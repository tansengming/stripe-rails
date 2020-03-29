require 'spec_helper'
require 'stripe/rails/testing'

describe "Testing" do
  let(:observer)  { Class.new }
  let(:event)     { observer.instance_variable_get :@event }
  let(:target)    { observer.instance_variable_get :@target }

  before do
    StripeMock.start

    observer.include Stripe::Callbacks
    observer.class_eval do
      after_invoice_payment_succeeded! { |target, event| @event, @target = event, target }
    end
  end
  
  after do
    ::Stripe::Callbacks.clear_callbacks!
    StripeMock.stop
  end

  describe '.send_event' do
    subject { Stripe::Rails::Testing.send_event event_name }

    describe 'when forwarding the event to the callback' do
      let(:event_name) { "invoice.payment_succeeded" }

      it 'the callback must run' do
        subject
        _(event).wont_be_nil
        _(event.type).must_equal "invoice.payment_succeeded"
      end
    end

    describe 'when forwarding the event to another callback' do
      let(:event_name) { 'customer.created' }

      it 'the callback must not run' do
        subject
        _(event).must_be_nil
      end
    end

    describe 'when overwriting event properties' do
      subject { Stripe::Rails::Testing.send_event event_name, params }
      let(:event_name) { "invoice.payment_succeeded" }
      let(:params)     { { subtotal: 500, total: 1000, currency: "eur" } }

      it 'the callback should run with overwritten properties' do
        subject
        _(event).wont_be_nil
        _(event.type).must_equal "invoice.payment_succeeded"
        _(target.subtotal).must_equal 500
        _(target.total).must_equal 1000
        _(target.currency).must_equal "eur"
      end
    end
  end
end
