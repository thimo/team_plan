class DownloadTeamMembersController < ApplicationController
  include SortHelper

  def index
    @teams = []
    if params[:season_id].present?
      @season = policy_scope(Season).find(params[:season_id])

      @season.age_groups.male.asc.each do |age_group|
        @teams += teams_for(age_group)
      end
      @season.age_groups.female.asc.each do |age_group|
        @teams += teams_for(age_group)
      end

    elsif params[:age_group_id].present?
      @age_group = policy_scope(AgeGroup).find(params[:age_group_id])
      @season = @age_group.season

      @teams += teams_for(@age_group)

    elsif params[:team_id].present?
      @team = policy_scope(Team).find(params[:team_id])
      @season = @team.age_group.season

      @teams << team_hash(@team)
    end

    respond_to do |format|
       format.xlsx {render xlsx: 'download', filename: "#{Setting['company.name']} - #{@season.name} #{ " - #{@team.name}" if @team.present? } - #{Time.now}.xlsx"}
    end
  end

  private

    def teams_for(age_group)
      teams = []
      human_sort(age_group.teams, :name).each do |team|
        teams << team_hash(team)
      end
      teams
    end

    def team_hash(team)
      {
        season: team.age_group.season.name,
        age_group: team.age_group.name,
        team: team.name,
        players: team.team_members.player.asc,
        staff: team.team_members.staff.asc
      }
    end
end
