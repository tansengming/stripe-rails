require 'spec_helper'

describe "Testing" do
  include CallbackHelpers
  let(:observer)  { Class.new }

  before do
    StripeMock.start
    observer.include Stripe::Callbacks
    run_callback_with(:after_invoice_payment_succeeded!) {|target, e| @event = e; @target = target}
  end
  
  after do
    ::Stripe::Callbacks.clear_callbacks!
    StripeMock.stop
  end

  describe '.send_event' do
    subject { Stripe::Testing.send_event event_name }

    describe 'when forwarding the event to the registered callbacks' do
      let(:event_name) { "invoice.payment_succeeded" }

      it 'should work' do
        subject
        @event.wont_be_nil
        @event.type.must_equal "invoice.payment_succeeded"
      end
    end

    describe "doesn't forward the event to the other callbacks" do
      let(:event_name) { 'customer.created' }

      it 'should work' do
        subject
        @event.must_be_nil
      end
    end

    describe 'when overwriting event properties' do
      subject do 
        Stripe::Testing.send_event "invoice.payment_succeeded", {
          :subtotal => 500,
          :total => 1000,
          :currency => "eur"
        }
      end

      it 'should work' do
        subject
        @event.wont_be_nil
        @event.type.must_equal "invoice.payment_succeeded"
        @target.subtotal.must_equal 500
        @target.total.must_equal 1000
        @target.currency.must_equal "eur"
      end
    end
  end
end
