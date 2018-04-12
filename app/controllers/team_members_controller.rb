class TeamMembersController < ApplicationController
  include SortHelper

  before_action :create_team_member, only: [:new, :create]
  before_action :set_team_member, only: [:show, :edit, :update, :destroy, :activate]
  before_action :add_breadcrumbs, only: [:new, :edit]

  def show
    redirect_to @team_member.member
  end

  def new; end

  def create
    if params[:age_group_id].present?
      # Action from member allocations
      @age_group = AgeGroup.find(params[:age_group_id])

      if params[:team_member_id].present?
        # Remove player from previous team
        team_member = TeamMember.find(params[:team_member_id])
        authorize team_member
        team_member.deactivate
      end

      attrs = permitted_attributes(TeamMember.new).to_h
      member_ids = attrs.delete(:member_id).split(',')
      member_ids.each do |member_id|
        if (team_member = TeamMember.find_by(attrs.merge(member_id: member_id))).present?
          # Member already was in the team, but has previously been removed. Reset its status
          team_member.attributes = attrs.merge(role: :player, ended_on: nil, status: team_member.team.status)
        else
          team_member = TeamMember.new(attrs.merge(member_id: member_id))
        end
        authorize team_member

        if team_member.save
          team_member.member.logs << Log.new(body: "Toegevoegd aan #{team_member.team.name}.", user: current_user)
          flash_message(:success, "#{team_member.member.name} is aan #{team_member.team.name} toegevoegd")
          @team_members ||= []
          @team_members << team_member
        else
          flash_message(:alert, "Er is iets mis gegaan, de speler is niet toegevoegd")
        end
      end

      respond_to do |format|
        format.html {
          redirect_to age_group_member_allocations_path(@age_group)
        }
        format.js {
          @teams = human_sort(policy_scope(Team).where(age_group_id: @age_group.id).includes(:age_group), :name)
          @season = @age_group.season
          @previous_season = @season.previous
          render "create"
        }
      end
    else
      # @team_member.initial_draft? does not seem to work here
      if @team_member.initial_status != "initial_draft"
        # By default use team's status, otherwise use default 'status' value (draft)
        @team_member.status = @team.status
      end

      if @team_member.save
        return redirect_to @team
      else
        render :new
      end
    end
  end

  def activate
    # TODO: send notification to member administration
    @team_member.status = TeamMember.statuses[:active]
    @team_member.ended_on = nil
    @team_member.started_on = Time.zone.today if @team_member.draft?

    if @team_member.save
      @team_member.member.logs << Log.new(body: "Geactiveerd voor #{@team_member.team.name}.", user: current_user)
      flash_message(:success, "#{@team_member.member.name} is geactiveerd voor #{@team_member.team.name}.")
    else
      flash_message(:alert, "Er is iets mis gegaan, de teamgenoot is niet geactiveerd")
    end

    redirect_to back_url
  end

  def edit; end

  def update
    old_status = @team_member.status

    if @team_member.update(permitted_attributes(@team_member))
      @team_member.transmit_status(@team_member.status, old_status)

      redirect_to @team_member.team, notice: "Teamgenoot is aangepast."
    else
      render "edit"
    end
  end

  def destroy
    @team_member.deactivate(user: current_user)

    flash_message(:success, "#{@team_member.member.name} is verwijderd uit #{@team_member.team.name}.")
    redirect_to back_url
  end

  private

    def create_team_member
      return if params[:team_id].blank?

      @team = Team.find(params[:team_id])

      @team_member = if action_name == "new"
                       @team.team_members.new
                     else
                       TeamMember.new(permitted_attributes(TeamMember.new(team: @team)))
                     end
      @team_member.team ||= @team

      authorize @team_member
    end

    def set_team_member
      @team_member = TeamMember.find(params[:id])
      authorize @team_member
    end

    def add_breadcrumbs
      add_breadcrumb @team_member.team.age_group.season.name, @team_member.team.age_group.season
      add_breadcrumb @team_member.team.age_group.name, @team_member.team.age_group
      add_breadcrumb @team_member.team.name, @team_member.team
      if @team_member.new_record?
        add_breadcrumb "Nieuw"
      else
        add_breadcrumb @team_member.member.name, @team_member
      end
    end
end
