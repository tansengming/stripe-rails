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
    @content = JSON.parse(File.read File.expand_path('../invoice_payment_succeeded.json', __FILE__))
    Stripe::Event.stubs(:retrieve).with("evt_0jcGFxHNsrDTj4").returns(Stripe::Event.construct_from(@content))
  end

  after do
    ::Stripe::Callbacks.clear_callbacks!
  end

  it 'has a ping interface just to make sure that everything is working just fine' do
    get '/stripe/ping'
    assert last_response.ok?
  end

  describe 'defined with a bang' do
    code = nil
    before do
      code = proc {|e, target| @event = e; @target = target}
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
      @content['type'] = 'invoice.payment_failed'
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
end