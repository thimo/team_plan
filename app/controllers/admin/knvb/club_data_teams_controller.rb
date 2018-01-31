class Admin::Knvb::ClubDataTeamsController < AdminController
  def index
    @teams = policy_scope(ClubDataTeam).active.includes(:team).asc
  end
end
