class MemberAllocationsController < ApplicationController
  include SortHelper

  def index
    @age_group = AgeGroup.find(params[:age_group_id])
    @teams = human_sort(policy_scope(Team).where(age_group_id: @age_group.id).includes(:age_group), :name)
    @filter_field_position = session[:filter_field_position]

    members = @age_group.active_members

    @available_members = []
    # Filter out members who have already been assigned to a team
    members.each do |member|
      if (field_positions = session[:filter_field_position]).blank? || member.has_active_field_position?(field_positions)
        @available_members << member if @age_group.is_not_member(member)
      end
    end

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

    redirect_to :back, notice: "Teamlid is verwijderd uit het team."
  end

  private
end
