class MemberAllocationsController < ApplicationController
  include SortHelper

  def index
    @age_group = AgeGroup.find(params[:age_group_id])
    @teams = human_sort(policy_scope(Team).where(age_group_id: @age_group.id).includes(:age_group), :name)
    @filter_field_position = session[:filter_field_position]
    @filter_team = session[:filter_team]

    members = @age_group.active_members
    members = members.by_season(Season.active.last).by_field_position(field_positions) if field_positions.present?
    members = members.by_team(session[:filter_team]) if session[:filter_team].present?

    assigned_members = @age_group.assigned_active_members

    @available_members = members - assigned_members

    @teams_for_filter = [["Filter op team", ""]] + human_sort(Team.for_members(@age_group.active_members).for_season(Season.active.last).distinct, :name).map{|team| [team.name, team.id]}

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

    redirect_to :back, notice: 'Teamlid is verwijderd uit het team.'
  end

  private

    def field_positions
      session[:filter_field_position].map(&:to_i) if session[:filter_field_position].present?
    end
end
