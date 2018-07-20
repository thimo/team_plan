# frozen_string_literal: true

class PublishTeamMembersController < ApplicationController
  include SortHelper
  layout "blank"

  def index
    @teams = []

    # TODO: Filter for team status

    @season = policy_scope(Season).find(params[:season_id])

    @age_groups = sorted_age_groups.map do |age_group|
      teams = age_group.teams
      teams = teams.where(status: params[:status]) if params[:status].present?

      {
        name: age_group.name,
        teams: human_sort(teams, :name).reject { |team| team.name == "Niet indelen" }
      }
    end
  end

  private

    def sorted_age_groups
      human_sort(policy_scope(AgeGroup).where(id: params[:age_group_ids]), :name)
    end
end
