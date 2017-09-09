class Admin::ClubData::TeamsController < AdminController
  def index
    @teams = policy_scope(ClubDataTeam).active.includes(:team).asc
  end
end
