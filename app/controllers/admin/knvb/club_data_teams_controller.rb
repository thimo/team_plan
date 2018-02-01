class Admin::Knvb::ClubDataTeamsController < Admin::BaseController
  def index
    @teams = policy_scope(ClubDataTeam).active.includes(:team).asc
  end
end
