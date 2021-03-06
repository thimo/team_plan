class MemberAllocationsController < ApplicationController
  include SortHelper

  def index
    @age_group = AgeGroup.find(params[:age_group_id])
    authorize(Team.new(age_group: @age_group), :create?)
    @teams = human_sort(policy_scope(Team).where(age_group_id: @age_group.id).includes(:age_group), :name)
    @filter_field_position = session[:filter_field_position]
    @filter_team = session[:filter_team]

    @season = @age_group.season
    @previous_season = @season.previous

    active_players = @age_group.active_players.asc
    assigned_players = @age_group.assigned_active_players.asc
    @available_players = active_players - assigned_players

    @teams_for_filter = human_sort(Team.for_members(@available_players).as_player
                                       .for_season(@season.previous).distinct, :name)
      .map { |team| [team.name, team.id] }

    filtered_players = active_players
    if field_positions.present?
      filtered_players = filtered_players.by_season(Season.active.last).by_field_position(field_positions)
    end
    filtered_players = filtered_players.by_team(session[:filter_team]) if session[:filter_team].present?

    @filtered_available_players = (filtered_players - assigned_players)
      .group_by { |member| member.teams_for_season(@previous_season).as_player.first }
      .sort_by { |team, _members| team.present? ? team.name : "ZZZ" }

    add_breadcrumb @age_group.season.name.to_s, @age_group.season
    add_breadcrumb @age_group.name.to_s, @age_group
    add_breadcrumb "Indeling"
  end

  def create
  end

  def update
  end

  def destroy
    @team_member = TeamMember.find(params[:id])
    authorize @team_member
    @team_member.destroy

    @team_member.member.logs << Log.new(body: "Verwijderd uit #{@team_member.team.name}.", user: current_user)
    redirect_to :back, notice: "#{@team_member.member.name} is verwijderd uit #{@team_member.team.name}."
  end

  private

  def field_positions
    @field_positions ||= init_field_positions
  end

  def init_field_positions
    positions = []
    if (id = session[:filter_field_position]).present?
      positions << id
      ids = FieldPosition.find(id).axis_children.pluck(:id)
      positions << ids if ids.present?
      ids = FieldPosition.find(id).line_children.pluck(:id)
      positions << ids if ids.present?
    end
    positions.flatten
  end
end
