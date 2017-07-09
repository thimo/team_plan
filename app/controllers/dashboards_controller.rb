class DashboardsController < ApplicationController
  def index
    @season = policy_scope(Season).active.last

    @age_groups_male = policy_scope(@season.age_groups).male.asc
    @age_groups_female = policy_scope(@season.age_groups).female.asc

    @active_teams = policy_scope(current_user.active_teams)
    @favorite_teams = policy_scope(current_user.favorite_teams)
    @favorite_age_groups = policy_scope(current_user.favorite_age_groups)

    team_ids = current_user.teams_as_staff_in_season(@season).collect(&:id).uniq
    @open_team_evaluations = policy_scope(TeamEvaluation).desc.where(team_id: team_ids)

    @version_updates = policy_scope(VersionUpdate).desc.limit(10)
    @todos = policy_scope(Todo).asc.open

    skip_policy_scope
  end
end
