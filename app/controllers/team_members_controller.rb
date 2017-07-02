class TeamMembersController < ApplicationController
  include SortHelper

  # before_action :create_team_member, only: [:new, :create]
  before_action :set_team_member, only: [:show, :edit, :update, :destroy, :activate]
  before_action :add_breadcrumbs, only: [:edit]

  def show
    redirect_to @team_member.member
  end

  def new
    @team = Team.find(params[:team_id])

    @team_member = @team.team_members.new
    # @team_member.team = @team

    authorize @team_member
  end

  def create
    if params[:age_group_id].present?
      # Action from member allocations
      @age_group = AgeGroup.find(params[:age_group_id])

      if params[:team_member_id].blank?
        # A new assignment
        @team_member = TeamMember.new(permitted_attributes(TeamMember.new))
        authorize @team_member
        save_success = @team_member.save

        @team_member.member.logs << Log.new(body: "Toegevoegd aan #{@team_member.team.name}.", user: current_user) if save_success
      else
        # Move a player to another team
        @team_member = TeamMember.find(params[:team_member_id])
        authorize @team_member
        save_success = @team_member.update_attributes(permitted_attributes(@team_member))

        @team_member.member.logs << Log.new(body: "Verplaatst naar #{@team_member.team.name}.", user: current_user) if save_success
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
    else
      @team = Team.find(params[:team_id])
      @team_member = TeamMember.new(permitted_attributes(TeamMember.new))
      @team_member.team ||= @team
      authorize @team_member

      if @team_member.save
        return redirect_to @team
      else
        render :new
      end
    end
  end

  def activate
    # TODO send notification to member administration
    @team_member.status = TeamMember.statuses[:active]
    @team_member.ended_on = nil
    @team_member.started_on = Date.today if @team_member.draft?

    if @team_member.save
      @team_member.member.logs << Log.new(body: "Geactiveerd voor #{@team_member.team.name}.", user: current_user)
      flash[:success] = "#{@team_member.member.name} is geactiveerd voor #{@team_member.team.name}."
    else
      flash[:alert] = "Er is iets mis gegaan, de teamgenoot is niet geactiveerd"
    end

    redirect_to back_url
  end

  def edit;end

  def update
    old_status = @team_member.status

    if @team_member.update_attributes(permitted_attributes(@team_member))
      @team_member.transmit_status(@team_member.status, old_status)

      redirect_to @team_member.team, notice: 'Teamgenoot is aangepast.'
    else
      render 'edit'
    end
  end

  def destroy
    if @team_member.active?
      # TODO send notification to member administration
      @team_member.status = TeamMember.statuses[:archived]
      @team_member.ended_on = Date.today
      @team_member.save

      # Place team member in archive
      @team_member.member.logs << Log.new(body: "Gearchiveerd vanuit #{@team_member.team.name}.", user: current_user)
    else
      @team_member.destroy

      @team_member.member.logs << Log.new(body: "Verwijderd uit #{@team_member.team.name}.", user: current_user)
    end

    flash[:success] = "#{@team_member.member.name} is verwijderd uit #{@team_member.team.name}."
    redirect_to back_url
  end

  private

    # def create_team_member
    #   @team = Team.find(params[:team_id])
    #
    #   @team_member = if action_name == 'new'
    #             @team.team_members.new
    #           else
    #             TeamMember.new(permitted_attributes(TeamMember.new))
    #           end
    #   @team_member.team = @team
    #
    #   authorize @team_member
    # end

    def set_team_member
      @team_member = TeamMember.find(params[:id])
      authorize @team_member
    end

    def add_breadcrumbs
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
