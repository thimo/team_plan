class Admin::ClubData::TeamsController < AdminController
  include SortHelper

  def index
    @teams = policy_scope(ClubDataTeam).active.asc
  end
end
