require File.expand_path("null_system_test_case", __dir__)

# For Rails 4 compat
SystemTestCaseKlass = defined?(ActionDispatch::SystemTestCase) ? ActionDispatch::SystemTestCase : NullSystemTestCase

class ApplicationSystemTestCase < SystemTestCaseKlass
  driven_by :selenium_chrome_headless
end