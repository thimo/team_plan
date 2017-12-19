class Admin::ClubData::TeamsController < Admin::BaseController
  def index
    @teams = policy_scope(ClubDataTeam).active.includes(:team).asc
  end
end
