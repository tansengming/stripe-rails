class CurrentApiVersion
  def self.call
    Stripe.api_version || begin
      resp, _ = Stripe::Plan.request(:get, Stripe::Plan.resource_url)
      resp.http_headers['stripe-version']
    end
  end

  def self.after_switch_to_products_in_plans?
    Date.parse(call) >= Date.parse('2018-02-05')
  end
end
