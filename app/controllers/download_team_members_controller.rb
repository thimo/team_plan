class DownloadTeamMembersController < ApplicationController
  include SortHelper

  def index
    @teams = []
    if params[:season_id].present?
      @season = policy_scope(Season).find(params[:season_id])

      policy_scope(@season.age_groups).male.asc.each do |age_group|
        @teams += hashes_for(age_group.teams)
      end
      policy_scope(@season.age_groups).female.asc.each do |age_group|
        @teams += hashes_for(age_group.teams)
      end

    elsif params[:age_group_id].present?
      @age_group = policy_scope(AgeGroup).find(params[:age_group_id])
      @season = @age_group.season

      if params[:team_ids].present?
        @teams += hashes_for(@age_group.teams.where(id: params[:team_ids]))
      else
        @teams += hashes_for(@age_group.teams)
      end

    elsif params[:team_id].present?
      @team = policy_scope(Team).find(params[:team_id])
      @season = @team.age_group.season

      @teams << team_hash(@team)
    end

    respond_to do |format|
       format.xlsx {render xlsx: 'download', filename: "#{Setting['club.name']}_#{@season.name}#{"_#{@team.name}" if @team.present?}_#{Time.now}.xlsx".gsub(' ', '')}
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
        players: team.team_members.player.asc,
        staff: team.team_members.staff.asc
      }
    end
end
