require 'minitest/autorun'
require 'spec_helper'

describe Stripe::Callbacks do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  before do
    header 'Accept', 'application/json'
    header 'Content-Type', 'application/json'
    @observer = Class.new.tap do |cls|
      cls.class_eval do
        include Stripe::Callbacks
      end
    end

    event                   = JSON.parse(File.read File.expand_path('../event.json', __FILE__))
    invoice                 = JSON.parse(File.read File.expand_path('../invoice.json', __FILE__))
    event['data']['object'] = invoice

    @content = event
    self.type = @content['type']
  end

  def type=(type)
    @content['type'] = type
    @stubbed_event = Stripe::Event.construct_from(@content)
    Stripe::Event.stubs(:retrieve).returns(@stubbed_event)
  end

  after do
    ::Stripe::Callbacks.clear_callbacks!
  end

  it 'has eager loaded the callbacks listed in the configuration' do
    assert Dummy.const_defined?(:ModelWithCallbacks), 'should have eager loaded'
    assert Dummy.const_defined?(:ModuleWithCallbacks), 'should have eager loaded'
  end

  it 'has a ping interface just to make sure that everything is working just fine' do
    get '/stripe/ping'
    assert last_response.ok?
  end

  describe 'defined with a bang' do
    code = nil
    before do
      code = proc {|target, e| @event = e; @target = target}
      @observer.class_eval do
        after_invoice_payment_succeeded! do |evt, target|
          code.call(evt, target)
        end
      end
    end
    it 'is invoked for the invoice.payment_succeeded event' do
      post 'stripe/events', JSON.pretty_generate(@content)
      @event.wont_be_nil
      @event.type.must_equal 'invoice.payment_succeeded'
      @target.total.must_equal 6999
    end
    it 'is not invoked for other types of events' do
      self.type = 'invoked.payment_failed'
      post 'stripe/events/', JSON.pretty_generate(@content)
    end
    describe 'if it raises an exception' do
      before do
        code = proc {fail 'boom!'}
      end
      it 'causes the whole webhook to fail' do
        proc {post 'stripe/events', JSON.pretty_generate(@content)}.must_raise RuntimeError
      end
    end
  end

  describe 'defined without a bang and raising an exception' do
    before do
      @observer.class_eval do
        after_invoice_payment_succeeded do |evt|
          fail 'boom!'
        end
      end
    end

    it 'does not cause the webhook to fail' do
      post 'stripe/events', JSON.pretty_generate(@content)
      last_response.status.must_be :>=, 200
      last_response.status.must_be :<, 300
    end
  end

  describe 'designed to catch any event' do
    events = nil
    before do
      events = []
      @observer.class_eval do
        after_stripe_event do |target, evt|
          events << evt
        end
      end
    end
    it 'gets invoked for any standard event' do
      self.type = 'invoice.payment_failed'
      post 'stripe/events/', JSON.pretty_generate(@content)
      events.first.type.must_equal 'invoice.payment_failed'
    end

    it 'gets invoked for any event whatsoever' do
      self.type = 'foo.bar.baz'
      post 'stripe/events/', JSON.pretty_generate(@content)
      events.first.type.must_equal 'foo.bar.baz'
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
        @observer.class_eval do
          after_invoice_updated! :only => :closed do |invoice, evt|
            events << evt
          end
        end
      end
      it 'does not fire events for with a prior attribute was specified' do
        post 'stripe/events', JSON.pretty_generate(@content)
        events.length.must_equal 0
      end
      it 'does fire events for which the prior attribute was specified' do
        @stubbed_event.data.previous_attributes['closed'] = true
        post 'stripe/events', JSON.pretty_generate(@content)
        events.length.must_equal 1
      end
    end
    describe 'specified as an array' do
      before do
        @observer.class_eval do
          after_invoice_updated! :only => [:currency, :subtotal] do |invoice, evt|
            events << evt
          end
        end
      end
      it 'does not fire events for which prior attributes were not specified' do
        post 'stripe/events', JSON.pretty_generate(@content)
        events.length.must_equal 0
      end
      it 'does fire events for which prior attributes were specified' do
        @stubbed_event.data.previous_attributes['subtotal'] = 699
        post 'stripe/events', JSON.pretty_generate(@content)
        events.length.must_equal 1
      end
    end
    describe 'specified as a lambda' do
      before do
        @observer.class_eval do
          after_invoice_updated :only => proc {|target, evt| evt.data.previous_attributes.to_hash.has_key? :closed} do |i,e|
            events << e
          end
        end
      end
      it 'does not fire events for which the lambda is not true' do
        post 'stripe/events', JSON.pretty_generate(@content)
        events.length.must_equal 0
      end

      it 'does fire events for when the lambda is true' do
        @stubbed_event.data.previous_attributes['closed'] = 'false'
        post 'stripe/events', JSON.pretty_generate(@content)
        events.length.must_equal 1
      end
    end
  end
end