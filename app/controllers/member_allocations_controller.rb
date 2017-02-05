class MemberAllocationsController < ApplicationController
  def index
    @team_member = TeamMember.new

    @age_group = AgeGroup.find(params[:age_group_id])
    @teams = policy_scope(Team).where(age_group_id: @age_group.id).includes(:team_member_players).includes(team_member_players: :member)

    members = policy_scope(Member).active_players.asc
    members = members.from_year(@age_group.year_of_birth_from) \
      unless @age_group.year_of_birth_from.nil?
    members = members.to_year(@age_group.year_of_birth_to) \
      unless @age_group.year_of_birth_to.nil?

    @available_members = []
    members.each do |member|
      @available_members << member if @age_group.is_not_member(member)
    end

    add_breadcrumb @age_group.season.name.to_s, @age_group.season
    add_breadcrumb @age_group.name.to_s, @age_group
    add_breadcrumb 'Indeling'
  end

  def create; end

  def update; end

  def destroy
    team_member = TeamMember.find(params[:id])
    authorize team_member
    team_member.destroy

    # redirect_to member_allocation_path(team_member.team.age_group.id)
    redirect_to :back
  end

  private
end
