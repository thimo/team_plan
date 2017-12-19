class Admin::ClubData::DashboardsController < Admin::BaseController
  def index
    authorize :club_data_dashboard, :index?
    skip_policy_scope
  end
end
