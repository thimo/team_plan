class DashboardsController < ApplicationController
  include SortHelper

  before_action :set_season

  def index
    @age_groups_male = policy_scope(@season.age_groups).male.asc
    @age_groups_female = policy_scope(@season.age_groups).female.asc

    @active_teams = human_sort(policy_scope(current_user.active_teams), :name)
    @favorite_teams = human_sort(policy_scope(current_user.favorite_teams), :name)
    @favorite_age_groups = human_sort(policy_scope(current_user.favorite_age_groups), :name)

    # Retrieve matches for own teams + favorite teams + favorite age groups
    team_ids = (
      current_user.active_teams.pluck(:id) +
      current_user.favorite_teams.pluck(:id) +
      current_user.favorite_age_groups.map{ |age_group| age_group.teams.pluck(:id)}
    ).flatten.uniq
    matches = policy_scope(Match).for_team(team_ids)

    not_played_matches = matches.not_played.in_period(0.days.ago.beginning_of_day, 1.week.from_now.beginning_of_day)
    # On many results, hide matches from over an hour ago (handy on match day if you have many favorites)
    not_played_matches = matches.not_played.in_period(1.hour.ago, 1.week.from_now.beginning_of_day) if not_played_matches.size > 10
    @not_played_matches = not_played_matches.asc.limit(10).group_by{ |match| match.wedstrijddatum.to_date }

    @played_matches = matches.played.in_period(1.week.ago.end_of_day, 0.hour.ago).desc.limit(10).group_by{ |match| match.wedstrijddatum.to_date }

    team_ids = current_user.teams_as_staff_in_season(@season).collect(&:id).uniq
    @open_team_evaluations = policy_scope(TeamEvaluation).desc.where(team_id: team_ids)

    @version_updates = policy_scope(VersionUpdate).desc.page(params[:version_page]).per(3)
    @todos = policy_scope(Todo).includes(:todoable).asc.unfinished
    @new_members = policy_scope(Member).recent_members(30).page(params[:member_page]).per(6) if policy(Member).show_new_members?

    skip_policy_scope
  end

  def program
    authorize Match, :show?
    @not_played_matches = policy_scope(Match).own.not_played.asc.in_period(0.days.ago.beginning_of_day, 1.week.from_now.end_of_day).group_by{ |match| match.wedstrijddatum.to_date }
  end

  def results
    authorize Match, :show?
    @played_matches = policy_scope(Match).own.played.desc.in_period(1.week.ago.end_of_day, 0.days.from_now.end_of_day).group_by{ |match| match.wedstrijddatum.to_date }
  end

  def cancellations
    authorize Match, :show?
    @cancelled_matches = policy_scope(Match).own.afgelast
  end

  private

    def set_season
      @season = policy_scope(Season).active.last
    end
end
