class MemberAllocationsController < ApplicationController
  include SortHelper

  def index
    @age_group = AgeGroup.find(params[:age_group_id])
    @teams = human_sort(policy_scope(Team).where(age_group_id: @age_group.id).includes(:age_group), :name)
    @filter_field_position = session[:filter_field_position]
    @filter_team = session[:filter_team]

    active_members = @age_group.active_members
    assigned_members = @age_group.assigned_active_members
    @available_members = active_members - assigned_members

    @teams_for_filter = human_sort(Team.for_members(@available_members).for_season(Season.active.last).distinct, :name).map{|team| [team.name, team.id]}

    filtered_members = active_members
    filtered_members = filtered_members.by_season(Season.active.last).by_field_position(field_positions) if field_positions.present?
    filtered_members = filtered_members.by_team(session[:filter_team]) if session[:filter_team].present?
    @filtered_available_members = filtered_members - assigned_members

    add_breadcrumb @age_group.season.name.to_s, @age_group.season
    add_breadcrumb @age_group.name.to_s, @age_group
    add_breadcrumb 'Indeling'
  end

  def create; end

  def update; end

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
