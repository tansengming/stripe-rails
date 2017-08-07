require "capybara/poltergeist"
require 'phantomjs/poltergeist'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :poltergeist, options: { js_errors: true, inspector: true, phantomjs: Phantomjs.path }
end