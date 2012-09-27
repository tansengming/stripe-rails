require 'minitest/autorun'
require 'spec_helper'

# Expectations:  http://bfts.rubyforge.org/minitest/MiniTest/Expectations.html

describe "Configuring the stripe" do
  it "true should be true" do
    @boolean = true
    @boolean.must_equal true
  end
  
  it "should be a module" do
    assert_kind_of Module, Stripe::Rails
  end
end
