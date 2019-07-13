# frozen_string_literal: true

class TrainingSchedulesController < ApplicationController
  before_action :set_team, only: [:new, :create]
  before_action :create_training_schedule, only: [:new, :create]
  before_action :set_training_schedule, only: [:show, :edit, :update, :destroy, :activate]
  before_action :add_breadcrumbs

  # def show; end

  def new; end

  def show
    @presences = @training_schedule.find_or_create_presences&.asc
  end

  def create
    if @training_schedule.save
      redirect_to @training_schedule, notice: "Trainingsdag is toegevoegd."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @training_schedule.update(training_schedule_params)
      redirect_to @training_schedule, notice: "Trainingsdag is aangepast."
    else
      render "edit"
    end
  end

  def destroy
    redirect_to @training_schedule.team, notice: "Trainingsdag is verwijderd."
    @training_schedule.deactivate
  end

  def activate
    redirect_to @training_schedule.team, notice: "Trainingsdag is geactiveerd."
    @training_schedule.activate
  end

  private

    def set_team
      @team = @training_schedule&.team || Team.find(params[:team_id])
    end

    def create_training_schedule
      @training_schedule = if action_name == "new"
                             @team.training_schedules.new(start_time: Time.zone.local(2000, 1, 1, 19, 0),
                                                          end_time: Time.zone.local(2000, 1, 1, 20, 0))
                           else
                             TrainingSchedule.new(training_schedule_params)
                           end
      @training_schedule.team = @team
      check_and_set_dates @training_schedule

      authorize @training_schedule
    end

    def set_training_schedule
      @training_schedule = TrainingSchedule.find(params[:id])
      check_and_set_dates @training_schedule
      authorize @training_schedule
    end

    def training_schedule_params
      params.require(:training_schedule).permit(:day, :present_minutes, :start_time, :end_time, :soccer_field_id,
                                                :field_part, :cios, :started_on, :ended_on, team_member_ids: [])
    end

    def add_breadcrumbs
      add_breadcrumb @training_schedule.team.age_group.season.name, @training_schedule.team.age_group.season
      add_breadcrumb @training_schedule.team.age_group.name, @training_schedule.team.age_group
      add_breadcrumb @training_schedule.team.name_with_club, @training_schedule.team
      if @training_schedule.new_record?
        add_breadcrumb "Nieuw"
      else
        add_breadcrumb @training_schedule.day_i18n, @training_schedule
      end
    end

    def check_and_set_dates(training_schedule)
      training_schedule.started_on ||= training_schedule.team.age_group.season.started_on
      training_schedule.ended_on ||= training_schedule.team.age_group.season.ended_on
    end
end
