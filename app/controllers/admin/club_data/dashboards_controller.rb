class Admin::ClubData::DashboardsController < AdminController
  def index
    # TODO add Pundit check, not through policy_scope
    authorize :club_data_dashboard, :index?
    skip_policy_scope
  end
end
