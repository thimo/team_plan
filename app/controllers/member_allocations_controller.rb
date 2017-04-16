class MemberAllocationsController < ApplicationController
  include SortHelper

  def index
    @age_group = AgeGroup.find(params[:age_group_id])
    @teams = human_sort(policy_scope(Team).where(age_group_id: @age_group.id).includes(:age_group), :name)
    @filter_field_position = session[:filter_field_position]

    members = @age_group.active_members
    assigned_members = @age_group.assigned_active_members

    field_positions = session[:filter_field_position].map(&:to_i) if session[:filter_field_position].present?
    @available_members = if field_positions.blank?
                           members - assigned_members
                         else
                           @age_group.active_members_by_field_position(field_positions) - assigned_members
                         end

    @filter_teams = human_sort(Team.for_members(members).for_season(Season.active.last).distinct, :name).map(&:name)

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
end
