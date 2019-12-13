# frozen_string_literal: true

class TrainingsController < ApplicationController
  include SchedulesHelper

  before_action :set_team, only: [:new, :create]
  before_action :create_training, only: [:new, :create]
  before_action :set_training, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs

  def show
    @presences = @training.find_or_create_presences.asc if policy(@training).show_presences?
  end

  def new; end

  def create
    if @training.save
      redirect_to @training, notice: "Training is toegevoegd."
    else
      render :new
    end
  end

  def edit
    @trainings_with_program = policy_scope(@training.team.trainings).with_program.limit(4).desc.active
  end

  def update
    if @training.update(training_params.merge(user_modified: true))
      redirect_to @training, notice: "Training is aangepast."
    else
      render "edit"
    end
  end

  def destroy
    redirect_to @training.team, notice: "Training is verwijderd."
    @training.destroy
  end

  private

    def set_team
      @team = @training&.team || Team.find(params[:team_id])
    end

    def create_training
      @training = if action_name == "new"
                    @team.trainings.new(started_at: Time.zone.now.change(hour: 19),
                                        ended_at: Time.zone.now.change(hour: 20))
                  else
                    Training.new(training_params.merge(user_modified: true))
                  end
      @training.team = @team

      authorize @training
    end

    def set_training
      @training = Training.find(params[:id])
      authorize @training
    end

    def training_params
      params.require(:training).permit(:body, :team_id, :started_at, :ended_at, :start_time, :end_time)
    end

    def add_breadcrumbs
      add_breadcrumb @training.team.name_with_club, @training.team
      if @training.new_record?
        add_breadcrumb "Nieuw"
      else
        add_breadcrumb @training.schedule_title, @training
      end
    end
end
