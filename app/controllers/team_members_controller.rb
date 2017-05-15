class TeamMembersController < ApplicationController
  include SortHelper

  before_action :set_team_member, only: [:show, :edit, :update, :destroy, :activate]
  before_action :breadcumbs, only: [:edit]

  def show
    redirect_to @team_member.member
  end

  def create
    @age_group = AgeGroup.find(params[:age_group_id])

    if params[:team_member_id].blank?
      # A new assignment
      @team_member = TeamMember.new(permitted_attributes(TeamMember.new))
      authorize @team_member
      save_success = @team_member.save

      @team_member.member.logs << Log.new(body: "Toegevoegd aan #{@team_member.team.name}.", user: current_user)
    else
      # Move a player to another team
      @team_member = TeamMember.find(params[:team_member_id])
      authorize @team_member
      save_success = @team_member.update_attributes(permitted_attributes(@team_member))

      @team_member.member.logs << Log.new(body: "Verplaatst naar #{@team_member.team.name}.", user: current_user)
    end

    if save_success
      flash[:success] = "#{@team_member.member.name} is aan #{@team_member.team.name} toegevoegd"
    else
      flash[:alert] = "Er is iets mis gegaan, de speler is niet toegevoegd"
    end

    respond_to do |format|
      format.html {
        redirect_to age_group_member_allocations_path(@age_group)
      }
      format.js {
        @teams = human_sort(policy_scope(Team).where(age_group_id: @age_group.id).includes(:age_group), :name)
        render "create"
      }
    end
  end

  def activate
    # Place team member in archive
    @team_member.member.logs << Log.new(body: "Geactiveerd voor #{@team_member.team.name}.", user: current_user)
    @team_member.update_columns(status: TeamMember.statuses[:active], started_on: Date.today, ended_on: nil)

    redirect_to @team_member.team
  end

  def edit;end

  def update
    old_status = @team_member.status

    if @team_member.update_attributes(permitted_attributes(@team_member))
      @team_member.transmit_status(@team_member.status, old_status)

      redirect_to @team_member.team, notice: 'Teamlid is aangepast.'
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to :back, notice: "#{@team_member.member.name} is verwijderd uit #{@team_member.team.name}."

    if @team_member.active?
      # Place team member in archive
      @team_member.member.logs << Log.new(body: "Gearchiveerd vanuit #{@team_member.team.name}.", user: current_user)
      @team_member.update_columns(status: TeamMember.statuses[:archived], ended_on: Date.today)
    else
      @team_member.member.logs << Log.new(body: "Verwijderd uit #{@team_member.team.name}.", user: current_user)
      @team_member.destroy
    end
  end

  private

    def set_team_member
      @team_member = TeamMember.find(params[:id])
      authorize @team_member
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
