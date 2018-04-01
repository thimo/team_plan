require 'test_helper'

class Admin::RolesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_roles_index_url
    assert_response :success
  end

  test "should get new" do
    get admin_roles_new_url
    assert_response :success
  end

  test "should get edit" do
    get admin_roles_edit_url
    assert_response :success
  end

end
