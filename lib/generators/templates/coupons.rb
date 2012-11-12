# Place all your static coupons that aren't generated at runtime here
# the next time you run rake stripe:prepare, they will be created on
# stripe.com
# details at https://stripe.com/docs/api?lang=curl#create_coupon

# This gives you 25% off for the first six months of a subscription
# offer ends June 5th, 2013
# Stripe.coupon 'launch_promotion' do |coupon|
#   # required
#   coupon.percent_off = 25
#   # required (forever | once | repeating)
#   coupon.duration = 'repeating'
#   # required if duration is repeating
#   coupon.duration_in_months = 6
#   # optional
#   coupon.max_redemptions = 1
#   # optional, if not a Date or Time object, must be parseable by Time.parse
#   coupon.redeem_by = '2013-06-05'
# end