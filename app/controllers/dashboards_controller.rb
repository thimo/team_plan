class DashboardsController < ApplicationController
  def index
    @season = Season.active.last
    @age_groups_male = @season.age_groups.male.asc
    @age_groups_female = @season.age_groups.female.asc

    team_ids = current_user.teams_as_staff_in_season(@season).collect(&:id).uniq
    @open_team_evaluations = policy_scope(TeamEvaluation).desc.where(team_id: team_ids)

    @version_updates = policy_scope(VersionUpdate).desc.limit(10)

    skip_policy_scope
  end
end
