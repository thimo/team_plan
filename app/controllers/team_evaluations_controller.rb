class TeamEvaluationsController < ApplicationController
  before_action :create_team_evaluation, only: [:new, :create]
  before_action :set_team_evaluation, only: [:show, :edit, :update, :destroy]
  before_action :breadcumbs

  def show; end

  def new
    # Create team evaluation
    @team_evaluation.team.team_members.player.asc.each do |player|
      @team_evaluation.player_evaluations.build(team_member: player)
    end
  end

  def create
    if @team_evaluation.save
      redirect_to @team_evaluation.team, notice: 'Team evaluatie is toegevoegd.'
    else
      render :new
    end
  end

  def edit; end

  def update
    finish_evaluation = params[:finish_evaluation].present?
    send_invite = params[:send_invite].present?

    @team_evaluation.enable_validation = finish_evaluation
    if @team_evaluation.update_attributes(team_evaluation_params)
      if finish_evaluation
        @team_evaluation.finish_evaluation(current_user)
        flash[:success] = 'De team evaluatie is afgerond.'
      elsif send_invite
        mail_count = @team_evaluation.send_invites(current_user)

        if mail_count == 0
          flash[:alert] = "De team evaluatie is opgeslagen, maar er zijn geen uitnodigingen verstuurd."
        else
          flash[:success] = "De team evaluatie is opgeslagen en <%= t(:invites_sent, count: mail_count) %>."
        end

      else
        flash[:success] = 'De team evaluatie is opgeslagen.'
      end

      redirect_to @team_evaluation.team
    else
      render :new
    end
  end

  def destroy
    redirect_to @team_evaluation.team, notice: 'Team evaluatie is verwijderd.'
    @team_evaluation.destroy
  end

  private

    def create_team_evaluation
      @team = Team.find(params[:team_id])

      @team_evaluation = if action_name == 'new'
                           @team.team_evaluations.new
                         else
                           TeamEvaluation.new(team_evaluation_params)
                         end
      @team_evaluation.team = @team
      authorize @team_evaluation
    end

    def set_team_evaluation
      @team_evaluation = TeamEvaluation.find(params[:id])
      authorize @team_evaluation
    end

    def breadcumbs
      add_breadcrumb @team_evaluation.team.age_group.season.name, @team_evaluation.team.age_group.season unless @team_evaluation.team.age_group.nil?
      add_breadcrumb @team_evaluation.team.age_group.name, @team_evaluation.team.age_group unless @team_evaluation.team.age_group.nil?
      add_breadcrumb @team_evaluation.team.name, @team_evaluation.team
      if @team_evaluation.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb 'Team evaluatie'
      end
    end

    def team_evaluation_params
      params.require(:team_evaluation).permit(player_evaluations_attributes: [:id, :team_member_id, :prefered_foot, :advise_next_season, :behaviour, :technique, :handlingspeed, :insight, :passes, :speed, :locomotion, :physical, :endurance, :duel_strength, :remark, team_member_attributes: [:id, field_position_ids: []]])
    end
end
