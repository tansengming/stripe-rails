class CurrentApiVersion
  def self.call
    Stripe.api_version || begin
      resp, _ = Stripe::Plan.request(:get, Stripe::Plan.resource_url)
      resp.http_headers['stripe-version']
    end
  end
end
