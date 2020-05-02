require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  Capybara.server = :puma, { Silent: true }
  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 1024]
end
