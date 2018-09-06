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
end