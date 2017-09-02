class DashboardsController < ApplicationController
  include SortHelper

  def index
    @season = policy_scope(Season).active.last

    @age_groups_male = policy_scope(@season.age_groups).male.asc
    @age_groups_female = policy_scope(@season.age_groups).female.asc

    @active_teams = human_sort(policy_scope(current_user.active_teams), :name)
    @favorite_teams = human_sort(policy_scope(current_user.favorite_teams), :name)
    @favorite_age_groups = human_sort(policy_scope(current_user.favorite_age_groups), :name)

    team_ids = current_user.teams_as_staff_in_season(@season).collect(&:id).uniq
    @open_team_evaluations = policy_scope(TeamEvaluation).desc.where(team_id: team_ids)

    @version_updates = policy_scope(VersionUpdate).desc.page(params[:version_page]).per(3)
    @todos = policy_scope(Todo).includes(:todoable).asc.open
    @new_members = policy_scope(Member).recent_members(30).page(params[:member_page]).per(6) if policy(Member).show_new_members?

    skip_policy_scope
  end
end
