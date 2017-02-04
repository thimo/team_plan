class TeamMembersController < ApplicationController
  before_action :set_team_member, only: [:edit, :update, :destroy]

  def create
    @year_group = YearGroup.find(params[:year_group_id])
    @team_member = TeamMember.new(team_member_params.merge(role: TeamMember.roles[:role_player]))
    authorize @team_member
    if @team_member.save
      redirect_to year_group_member_allocations_path(@year_group), notice: "Speler is aan #{@team_member.team.name} toegevoegd"
    else
      redirect_to year_group_member_allocations_path(@year_group), alert: "Er is iets mis gegaan, de speler is niet toegevoegd"
    end
  end

  def edit; end

  def destroy; end

  private

    def set_team_member
      @team_member = TeamMember.find(params[:id])
      authorize @team_member
    end

    def team_member_params
      params.require(:team_member).permit(:team_id, :member_id, :role)
    end
end
