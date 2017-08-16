require 'spec_helper'

describe ApisController do
  include Rack::Test::Methods

  let(:app) { Rails.application }
  before do
    header 'Accept', 'application/json'
    header 'Content-Type', 'application/json'
  end

  describe 'the ping interface' do
    subject { get '/apis/' }

    it { subject.must_be :ok? }
  end
end