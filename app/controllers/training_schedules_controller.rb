class TrainingSchedulesController < ApplicationController
  before_action :set_team, only: [:new, :create]
  before_action :create_training_schedule, only: [:new, :create]
  before_action :set_training_schedule, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs

  # def show; end

  def new
  end

  def create
    if @training_schedule.save
      redirect_to @training_schedule.team, notice: "Training is toegevoegd."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @training_schedule.update_attributes(training_schedule_params)
      redirect_to @training_schedule.team, notice: "Training is aangepast."
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to @training_schedule.team, notice: "Training is verwijderd."
    @training_schedule.destroy
  end

  private

    def set_team
      @team = if @training_schedule.present? && @training_schedule.team.present?
                @training_schedule.team
              else
                Team.find(params[:team_id])
              end
    end

    def create_training_schedule
      @training_schedule = if action_name == 'new'
                @team.training_schedules.new
              else
                TrainingSchedule.new(training_schedule_params)
              end
      @training_schedule.team = @team

      authorize @training_schedule
    end

    def set_training_schedule
      @training_schedule = TrainingSchedule.find(params[:id])
      authorize @training_schedule
    end

    def training_schedule_params
      params.require(:training_schedule).permit(:day, :present_time, :start_time, :end_time, :soccer_field_id, :field_part, :cios, team_member_ids: [])
    end

    def add_breadcrumbs
      add_breadcrumb "#{@training_schedule.team.age_group.season.name}", @training_schedule.team.age_group.season
      add_breadcrumb @training_schedule.team.age_group.name, @training_schedule.team.age_group
      add_breadcrumb @training_schedule.team.name, @training_schedule.team
      if @training_schedule.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb @training_schedule.day_i18n, @training_schedule
      end
    end

end
