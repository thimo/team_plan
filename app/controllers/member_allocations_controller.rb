class MemberAllocationsController < ApplicationController
  def index
    @year_group = YearGroup.find(params[:year_group_id])
    @teams = policy_scope(Team).where(year_group_id: @year_group.id).includes(:team_member_players).includes(team_member_players: :member)

    @available_members = policy_scope(Member).players
    @available_members = @available_members.from_year(@year_group.year_of_birth_from) unless @year_group.year_of_birth_from.nil?
    @available_members = @available_members.to_year(@year_group.year_of_birth_to) unless @year_group.year_of_birth_to.nil?

    add_breadcrumb "#{@year_group.season.name}", @year_group.season
    add_breadcrumb "#{@year_group.name}", @year_group
    add_breadcrumb "Indeling"
  end

  def create
  end

  def update
  end

  def destroy
    team_member = TeamMember.find(params[:id])
    authorize team_member
    team_member.destroy

    # redirect_to member_allocation_path(team_member.team.year_group.id)
    redirect_to :back
  end

  private



end
