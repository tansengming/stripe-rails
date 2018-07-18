require 'spec_helper'

describe 'building products' do
  describe 'simply' do
    before do
      Stripe.product :primo do |product|
        product.name = 'Acme as a service PRIMO'
        product.type = 'service'
      end
    end

    after { Stripe::Products.send(:remove_const, :PRIMO) }

    it 'is accessible via id' do
      Stripe::Products::PRIMO.wont_be_nil
    end

    it 'is accessible via collection' do
      Stripe::Products.all.must_include Stripe::Products::PRIMO
    end

    it 'is accessible via hash lookup (symbol/string agnostic)' do
      Stripe::Products[:primo].must_equal  Stripe::Products::PRIMO
      Stripe::Products['primo'].must_equal Stripe::Products::PRIMO
    end
  end

  describe 'validations' do
    describe 'with missing mandatory values' do
      it 'raises an exception after configuring it' do
        lambda { Stripe.product(:bad){} }.must_raise Stripe::InvalidConfigurationError
      end
    end
  end
end
