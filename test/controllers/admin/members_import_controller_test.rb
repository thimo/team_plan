require 'test_helper'

class Admin::MembersImportControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get admin_members_import_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_members_import_create_url
    assert_response :success
  end

end
