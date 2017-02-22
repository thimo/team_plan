require 'rails_helper'
require 'shared_contexts'

RSpec.describe Admin::UsersController, type: :request do
  describe "Unimplemented actions" do
    it "users#destroy should not be implemented" do
      user = create :user

      # show
      expect {
        get admin_user_path(user)
      }.to raise_error(ActionController::RoutingError)

      # destroy
      expect {
        delete admin_users_path(user)
      }.to raise_error(ActionController::RoutingError)
    end
  end
end
