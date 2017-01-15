require 'test_helper'

class YearGroupsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get year_groups_index_url
    assert_response :success
  end

  test "should get show" do
    get year_groups_show_url
    assert_response :success
  end

  test "should get new" do
    get year_groups_new_url
    assert_response :success
  end

  test "should get edit" do
    get year_groups_edit_url
    assert_response :success
  end

end
