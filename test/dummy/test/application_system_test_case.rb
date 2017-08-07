require "test_helper"
require "capybara/poltergeist"

 
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :poltergeist, options: { js_errors: true, inspector: true }
end