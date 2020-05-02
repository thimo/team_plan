class TeamEvaluationsController < ApplicationController
  # before_action :create_resource, only: [:new, :create]
  before_action :set_resource, only: [:show, :edit, :update, :destroy, :re_open]
  before_action :add_breadcrumbs

  def show; end

  # Directly creating a team evaluation has been disabled for now
  # def new
  #   # Create team evaluation
  #   @team_evaluation.team.team_members.active.player.asc.each do |player|
  #     @team_evaluation.player_evaluations.build(team_member: player)
  #   end
  # end

  # def create
  #   if @team_evaluation.save
  #     post_save_actions
  #   else
  #     flash.now[:error] = "Controleer alsjeblieft de velden hieronder"
  #     render :new
  #   end
  # end

  def edit
    update_team_members
  end

  def update
    @team_evaluation.enable_validation = finish_evaluation?

    if @team_evaluation.update(team_evaluation_params)
      post_save_actions
    else
      flash.now[:error] = "Controleer alsjeblieft de velden hieronder"
      render :new
    end
  end

  def destroy
    redirect_to @team_evaluation.team, notice: "Teamevaluatie is verwijderd."
    @team_evaluation.destroy
  end

  def re_open
    @team_evaluation.update!(finished_at: nil)
    flash_message(:success, "De teamevaluatie staat weer open voor wijzigingen.")
    redirect_to [:edit, @team_evaluation]
  end

  private

    # def create_resource
    #   @team = Team.find(params[:team_id])
    #
    #   @team_evaluation = if action_name == "new"
    #                        @team.team_evaluations.new(private: false, config: first_config)
    #                      else
    #                        TeamEvaluation.new(team_evaluation_params.merge(private: false))
    #                      end
    #   @team_evaluation.team = @team
    #   authorize @team_evaluation
    # end

    def set_resource
      @team_evaluation = TeamEvaluation.find(params[:id])
      authorize @team_evaluation
    end

    def add_breadcrumbs
      season = @team_evaluation.team.age_group.season
      add_breadcrumb season.name, season if season.present?

      age_group = @team_evaluation.team.age_group
      add_breadcrumb age_group.name, @team_evaluation.team.age_group if age_group.present?

      add_breadcrumb @team_evaluation.team.name_with_club, @team_evaluation.team
      if @team_evaluation.new_record?
        add_breadcrumb "Nieuw"
      else
        add_breadcrumb "Teamevaluatie"
      end
    end

    def team_evaluation_params
      params.require(:team_evaluation)
            .permit(:config_json, :hide_remark_from_player,
                    player_evaluations_attributes: [:id, :team_member_id, :prefered_foot, :advise_next_season,
                                                    :field_1, :field_2, :field_3, :field_4, :field_5,
                                                    :field_6, :field_7, :field_8, :field_9, :field_10,
                                                    :remark, team_member_attributes: [:id, field_position_ids: []]])
    end

    def finish_evaluation?
      params[:finish_evaluation].present?
    end

    def send_invite?
      params[:send_invite].present?
    end

    def stay_open?
      params[:save_and_stay_open].present?
    end

    def post_save_actions
      if finish_evaluation?
        @team_evaluation.finish_evaluation(current_user)
        flash_message(:success, "De teamevaluatie is afgerond.")
      elsif send_invite?
        mail_count = @team_evaluation.send_invites(current_user)

        if mail_count.zero?
          flash_message(:alert, "De teamevaluatie is opgeslagen, maar er zijn geen uitnodigingen verstuurd.")
        else
          flash_message(:success, "De teamevaluatie is opgeslagen en #{t(:invites_sent, count: mail_count)}.")
        end
      else
        flash_message(:success, "De teamevaluatie is opgeslagen.")
      end

      if stay_open?
        redirect_to [:edit, @team_evaluation]
      else
        redirect_to @team_evaluation.team
      end
    end

    def update_team_members
      player_evaluations = @team_evaluation.player_evaluations
      @team_evaluation.team.team_members.active.player.asc.each do |player|
        unless player_evaluations.any? { |player_evaluation| player_evaluation.team_member_id == player.id }
          @team_evaluation.player_evaluations.build(team_member: player)
        end
      end

      # remove archived
    end

    def first_config
      # Return first team evaluation config if there's only one
      policy_scope(TeamEvaluationConfig).first.config if policy_scope(TeamEvaluationConfig).active.size == 1
    end
end
