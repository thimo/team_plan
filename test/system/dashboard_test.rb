require "application_system_test_case"

class DashboardTest < ApplicationSystemTestCase
  test "visiting the index" do
    FactoryBot.create(:tenant, host: "127.0.0.1")

    visit root_url

    assert_selector "h1", text: "Inloggen"
  end
end
