require File.expand_path("../null_system_test_case",  __FILE__)
require "capybara/poltergeist"
require 'phantomjs/poltergeist'

SystemTestCaseKlass = defined?(ActionDispatch::SystemTestCase) ? ActionDispatch::SystemTestCase : NullSystemTestCase

class ApplicationSystemTestCase < SystemTestCaseKlass
  driven_by :poltergeist, options: { js_errors: true, inspector: true, phantomjs: Phantomjs.path }
end