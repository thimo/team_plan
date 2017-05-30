class Admin::ClubData::DashboardsController < AdminController
  def index
    authorize :club_data_dashboard, :index?
    skip_policy_scope
  end
end
