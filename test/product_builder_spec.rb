require 'spec_helper'

describe 'building products' do
  before do
    Stripe.product :primo do |product|
      product.name        = 'Acme as a service PRIMO'
      product.type        = 'service'
      product.active      = true
      product.attributes  = ['size', 'gender']
      product.metadata    = {:number_of_awesome_things => 5}
      product.statement_descriptor = 'PRIMO'
    end
  end

  after { Stripe::Products.send(:remove_const, :PRIMO) }

  it 'is accessible via id' do
    _(Stripe::Products::PRIMO).wont_be_nil
  end

  it 'is accessible via collection' do
    _(Stripe::Products.all).must_include Stripe::Products::PRIMO
  end

  it 'is accessible via hash lookup (symbol/string agnostic)' do
    _(Stripe::Products[:primo]).must_equal  Stripe::Products::PRIMO
    _(Stripe::Products['primo']).must_equal Stripe::Products::PRIMO
  end

  describe '.put!' do
    describe 'when none exists on stripe.com' do
      before { Stripe::Product.stubs(:retrieve).raises(Stripe::InvalidRequestError.new("not found", "id")) }

      it 'creates the plan online' do
        Stripe::Product.expects(:create).with(
          id: :primo,
          name: 'Acme as a service PRIMO',
          type: 'service',
          active: true,
          attributes: ['size', 'gender'],
          metadata: {:number_of_awesome_things => 5},
          statement_descriptor: 'PRIMO'
        )
        Stripe::Products::PRIMO.put!
      end
    end

    describe 'when it is already present on stripe.com' do
      before do
        Stripe::Product.stubs(:retrieve).returns(Stripe::Product.construct_from({
          :id => :primo,
          :name => 'Acme as a service PRIMO',
        }))
      end

      it 'is a no-op' do
        Stripe::Product.expects(:create).never
        Stripe::Products::PRIMO.put!
      end
    end
  end

  describe 'validations' do
    describe 'with missing mandatory values' do
      it 'raises an exception after configuring it' do
        _(lambda { Stripe.product(:bad){} }).must_raise Stripe::InvalidConfigurationError
      end
    end

    describe 'invalid type' do
      it 'raises an exception during configuration' do
        _(lambda {
          Stripe.product :broken do |product|
            product.name = 'Acme as a service BROKEN'
            product.type = 'anything'
          end
        }).must_raise Stripe::InvalidConfigurationError
      end
    end

    describe 'when using an attribute only for goods' do
      it 'raises an exception during configuration' do
        _(lambda {
          Stripe.product :broken do |product|
            product.name        = 'Broken Service'
            product.type        = 'service'
            product.caption     = 'So good it is Primo'
          end
        }).must_raise Stripe::InvalidConfigurationError
      end
    end

    describe 'when using an attribute only for services' do
      it 'raises an exception during configuration' do
        _(lambda {
          Stripe.product :broken do |product|
            product.name        = 'Broken Good'
            product.type        = 'good'
            product.statement_descriptor = 'SERVICE'
          end
        }).must_raise Stripe::InvalidConfigurationError
      end
    end
  end
end
