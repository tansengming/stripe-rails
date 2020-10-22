require 'spec_helper'

describe ApisController do
  include Rack::Test::Methods

  let(:app) { Rails.application }
  before do
    header 'Accept', 'application/json'
    header 'Content-Type', 'application/json'
  end

  describe 'the apis interface' do
    subject { get '/apis/' }

    it { _(subject).must_be :ok? }
  end
end