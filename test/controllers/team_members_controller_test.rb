require 'test_helper'

class TeamMembersControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get team_members_show_url
    assert_response :success
  end

  test "should get new" do
    get team_members_new_url
    assert_response :success
  end

  test "should get edit" do
    get team_members_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get team_members_destroy_url
    assert_response :success
  end

end
