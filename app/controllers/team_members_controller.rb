class TeamMembersController < ApplicationController
  before_action :set_team_member, only: [:show, :edit, :update, :destroy]
  before_action :breadcumbs

  def show
    redirect_to @team_member.member
  end
  
  def create
    @age_group = AgeGroup.find(params[:age_group_id])

    if params[:team_member_id].blank?
      # A new assignment
      @team_member = TeamMember.new(team_member_params.merge(role: TeamMember.roles[:player]))
      authorize @team_member
      save_success = @team_member.save
    else
      # Move a player to another team
      @team_member = TeamMember.find(params[:team_member_id])
      authorize @team_member
      save_success = @team_member.update_attributes(team_member_params.merge(role: TeamMember.roles[:player]))
    end

    if save_success
      flash[:success] = "#{@team_member.member.name} is aan #{@team_member.team.name} toegevoegd"
    else
      flash[:alert] = "Er is iets mis gegaan, de speler is niet toegevoegd"
    end

    redirect_to age_group_member_allocations_path(@age_group)
  end

  def edit;end

  def update
    if @team_member.update_attributes(team_member_params)
      redirect_to @team_member.team, notice: 'Teamlid is aangepast.'
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to :back, notice: "#{@team_member.member.name} is verwijderd uit #{@team_member.team.name}."
    @team_member.destroy
  end

  private

    def set_team_member
      @team_member = TeamMember.find(params[:id])
      authorize @team_member
    end

    def team_member_params
      params_permitted = [:team_id, :member_id, :prefered_foot, field_position_ids: []]
      params_permitted << :role if current_user.club_staff? || current_user.admin?

      params.require(:team_member).permit(params_permitted)
    end

    def breadcumbs
      add_breadcrumb "#{@team_member.team.age_group.season.name}", @team_member.team.age_group.season
      add_breadcrumb @team_member.team.age_group.name, @team_member.team.age_group
      add_breadcrumb @team_member.team.name, @team_member.team
      if @team_member.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb @team_member.member.name, @team_member
      end
    end
end
