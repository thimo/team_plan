class DownloadTeamMembersController < ApplicationController
  include SortHelper

  def index
    @teams = []
    if params[:season_id].present?
      @season = policy_scope(Season).find(params[:season_id])

      if params[:age_group_ids].present?
        AgeGroup.where(id: params[:age_group_ids]).each do |age_group|
          @teams += hashes_for(age_group.teams)
        end
      else
        policy_scope(@season.age_groups).male.asc.each do |age_group|
          @teams += hashes_for(age_group.teams)
        end
        policy_scope(@season.age_groups).female.asc.each do |age_group|
          @teams += hashes_for(age_group.teams)
        end
      end

      @previous_season = @season.previous

    elsif params[:age_group_id].present?
      @age_group = policy_scope(AgeGroup).find(params[:age_group_id])
      @season = @age_group.season
      teams = @age_group.teams
      teams = teams.where(status: params[:status].to_sym) if params[:status].present?

      if params[:team_ids].present?
        @teams += hashes_for(teams.where(id: params[:team_ids]))
      else
        @teams += hashes_for(teams)
      end

      @previous_season = @age_group.season.previous

    elsif params[:team_id].present?
      @team = policy_scope(Team).find(params[:team_id])
      @season = @team.age_group.season

      @teams << team_hash(@team)

      @previous_season = @team.age_group.season.previous
    end

    @export_columns = current_user.export_columns

    filename = "#{Setting['club.name']}_#{@season.name}"
    filename += "_#{@age_group.name}" if @age_group.present?
    filename += "_#{@team.name}" if @team.present?
    filename += "_#{Time.zone.now}.xlsx"

    respond_to do |format|
       format.xlsx {render xlsx: 'download', filename: filename.gsub(' ', '')}
    end
  end

  private

    def hashes_for(teams)
      team_hashes = []
      human_sort(policy_scope(teams), :name).each do |team|
        team_hashes << team_hash(team)
      end
      team_hashes
    end

    def team_hash(team)
      {
        season: team.age_group.season.name,
        age_group: team.age_group.name,
        team: team.name,
        players: team.team_members.active_for_team(team).player.asc,
        staff: team.team_members.active_for_team(team).staff.asc
      }
    end
end
