require "application_system_test_case"

class DashboardTest < ApplicationSystemTestCase
  test "visiting the index" do
    visit dashboards_url

    assert_selector "h1", text: "Dashboard"
  end
end
