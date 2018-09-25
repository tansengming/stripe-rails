require 'spec_helper'

describe Stripe::EventsController do
  parallelize_me!
  include Rack::Test::Methods

  let(:app) { Rails.application }
  before do
    header 'Accept', 'application/json'
    header 'Content-Type', 'application/json'
  end

  describe 'the events interface' do
    let(:params) {
      {
        id: 'evt_00000000000000',
        type: 'customer.updated',
        data: {object: 'customer'},
      }
    }
    subject { post '/stripe/events', params.to_json }

    it { subject.must_be :ok? }
  end

  describe 'signed webhooks' do
    before do
      header 'Stripe-Signature', 't=1537832721,v1=123,v0=123'
    end

    let(:params) {
      {
        id: 'evt_00000000000001',
        type: 'customer.updated',
        data: {
          object: 'customer',
          fingerprint: 'xxxyyyzzz'
        },
      }
    }

    subject { post '/stripe/events', params.to_json }

    it 'returns bad_request when invalid' do
      Stripe::Webhook.expects(:construct_event).raises(Stripe::SignatureVerificationError.new('msg', 'sig_header'))
      subject.must_be :bad_request?
    end

    it 'returns ok when valid' do
      Stripe::Webhook.expects(:construct_event).returns(Stripe::Event.construct_from(params))
      subject.must_be :ok?
    end
  end
end