require 'rails_helper'

RSpec.describe Admin::MembersController, type: :request do
  describe "Unimplemented actions" do
    it "should not be implemented" do
      member = create :member

      # new
      expect {
        get new_admin_member_path
      }.to raise_error(NameError)

      # create
      expect {
        post admin_members_path
      }.to raise_error(ActionController::RoutingError)

      # edit
      expect {
        get edit_admin_member_path(member)
      }.to raise_error(NameError)

      # update
      expect {
        post admin_members_path(member)
      }.to raise_error(ActionController::RoutingError)

      # destroy
      expect {
        delete admin_members_path(member)
      }.to raise_error(ActionController::RoutingError)
    end
  end
end
