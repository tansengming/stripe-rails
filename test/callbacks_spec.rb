require 'spec_helper'

describe Stripe::Callbacks do
  include Rack::Test::Methods
  include CallbackHelpers

  let(:app)       { Rails.application }
  let(:event)     { JSON.parse(File.read File.expand_path('event.json', __dir__)) }
  let(:invoice)   { JSON.parse(File.read File.expand_path('invoice.json', __dir__)) }
  let(:content)   { event }
  let(:observer)  { Class.new }

  before do
    header 'Accept', 'application/json'
    header 'Content-Type', 'application/json'

    observer.include Stripe::Callbacks

    event['data']['object'] = invoice

    self.type = content['type']
  end
  after { ::Stripe::Callbacks.clear_callbacks! }

  subject { post 'stripe/events', JSON.pretty_generate(content) }

  describe 'defined with a bang' do
    let(:callback) { :after_invoice_payment_succeeded! }
    before { run_callback_with(callback) {|target, e| @event = e; @target = target} }

    describe 'when it is invoked for the invoice.payment_succeeded event' do
      it 'is invoked for the invoice.payment_succeeded event' do
        subject
        _(@event).wont_be_nil
        _(@event.type).must_equal 'invoice.payment_succeeded'
        _(@target.total).must_equal 6999
      end
    end

    describe 'when the invoked.payment_failed webhook is called' do
      before { self.type = 'invoked.payment_failed' }

      it 'the invoice.payment_succeeded callback is not invoked' do
        subject
        _(@event).must_be_nil
      end
    end

    describe 'if it raises an exception' do
      before { run_callback_with(callback) { fail } }

      it 'causes the whole webhook to fail' do
        _(-> { subject }).must_raise RuntimeError
      end
    end
  end

  describe 'defined without a bang and raising an exception' do
    let(:callback) { :after_invoice_payment_succeeded }
    before { run_callback_with(callback) { fail } }

    it 'does not cause the webhook to fail' do
      subject
      _(last_response.status).must_be :>=, 200
      _(last_response.status).must_be :<, 300
    end
  end

  describe 'the after_stripe_event callback to catch any event' do
    let(:events) { [] }
    before { run_callback_with(:after_stripe_event) { |_, evt| events << evt } }

    describe 'when it gets invoked for a standard event' do
      before { self.type = 'invoice.payment_failed' }

      it 'it will be run' do
        subject
        _(events.first.type).must_equal 'invoice.payment_failed'
      end
    end

    describe 'when it gets invoked for an arbitrary event' do
      before { self.type = 'foo.bar.baz' }

      it 'it will be run' do
        subject
        _(events.first.type).must_equal 'foo.bar.baz'
      end
    end
  end

  describe 'filtering on specific changed attributes' do
    events = nil
    before do
      events = []
      self.type = 'invoice.updated'
      @stubbed_event.data.previous_attributes = {}
    end

    describe 'specified as an single symbol' do
      before do
        observer.class_eval do
          after_invoice_updated! :only => :closed do |invoice, evt|
            events << evt
          end
        end
      end

      describe 'when a prior attribute was not specified' do
        it 'does not fire events' do
          subject
          _(events.length).must_equal 0
        end
      end

      describe 'when a prior attribute was specified' do
        before { @stubbed_event.data.previous_attributes['closed'] = true }
        it 'fires events' do
          subject
          _(events.length).must_equal 1
        end
      end
    end

    describe 'specified as an array' do
      before do
        observer.class_eval do
          after_invoice_updated! :only => [:currency, :subtotal] do |invoice, evt|
            events << evt
          end
        end
      end

      describe 'when a prior attribute was not specified' do
        it 'does not fire events' do
          subject
          _(events.length).must_equal 0
        end
      end

      describe 'when prior attributes were specified' do
        before { @stubbed_event.data.previous_attributes['subtotal'] = 699 }
        it 'fire events' do
          subject
          _(events.length).must_equal 1
        end
      end
    end

    describe 'specified as a lambda' do
      before do
        observer.class_eval do
          after_invoice_updated :only => proc {|target, evt| evt.data.previous_attributes.to_hash.has_key? :closed} do |i,e|
            events << e
          end
        end
      end

      describe 'when the lambda is not true' do
        it 'does not fire events' do
          subject
          _(events.length).must_equal 0
        end
      end

      describe 'when the lambda is not true' do
        before { @stubbed_event.data.previous_attributes['closed'] = 'false' }
        it 'fires events' do
          subject
          _(events.length).must_equal 1
        end
      end
    end
  end

  describe 'with forgery protection enabled' do
    before do
      ActionController::Base.allow_forgery_protection = true
      ActionController::Base.protect_from_forgery with: :exception
    end
    after { ActionController::Base.allow_forgery_protection = false }

    it { subject } # must_not raise error
  end
end