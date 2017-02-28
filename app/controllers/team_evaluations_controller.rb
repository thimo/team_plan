class TeamEvaluationsController < ApplicationController
  before_action :create_team_evaluation, only: [:new, :create]
  before_action :set_team_evaluation, only: [:show, :edit, :update, :destroy]
  before_action :breadcumbs

  def new
    # Create team evaluation
    @team_evaluation.team.team_members.player.asc.each do |player|
      # TODO add previous filled in values for player (field_position, prefered_foot)
      @team_evaluation.evaluations.build(member: player.member)
    end
    @evaluations = @team_evaluation.evaluations
  end

  def create
    if @team_evaluation.save
      redirect_to @team_evaluation.team, notice: 'Team evaluatie is toegevoegd.'
    else
      render :new
    end
  end

  def edit
    @evaluations = @team_evaluation.evaluations.asc
  end

  def update
    # TODO Add validatie indien af te ronden
    if @team_evaluation.update_attributes(team_evaluation_params)
      redirect_to @team_evaluation.team, notice: 'Team evaluatie is opgeslagen.'
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
      # TODO Currently not working, age_group is null. Could be Rails 5.1 problem
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
      params.require(:team_evaluation).permit(evaluations_attributes: [:id, :member_id, :field_position, :prefered_foot, :advise_next_season, :behaviour, :technique, :handlingspeed, :insight, :passes, :speed, :locomotion, :physical, :endurance, :duel_strength, :remark])
    end

end
