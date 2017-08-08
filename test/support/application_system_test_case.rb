require File.expand_path("../null_system_test_case",  __FILE__)
require "capybara/poltergeist"
require 'phantomjs/poltergeist'

# For Rails 4 compat
SystemTestCaseKlass = defined?(ActionDispatch::SystemTestCase) ? ActionDispatch::SystemTestCase : NullSystemTestCase

class ApplicationSystemTestCase < SystemTestCaseKlass
  # Note: errors only show up with BOTH js_errors: true, inspector: true
  driven_by :poltergeist, options: { js_errors: true, inspector: true, phantomjs: Phantomjs.path }
end