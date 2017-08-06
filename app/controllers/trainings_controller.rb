class TrainingsController < ApplicationController
  before_action :set_team, only: [:new, :create]
  before_action :create_training, only: [:new, :create]
  before_action :set_training, only: [:show, :edit, :update, :destroy]
  before_action :add_breadcrumbs

  def show
    @presences = policy_scope(@training.find_or_create_presences.asc)
  end

  def new
  end

  def create
    if @training.save
      redirect_to @training, notice: "Training is toegevoegd."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @training.update_attributes(training_params.merge(user_modified: true))
      redirect_to @training, notice: "Training is aangepast."
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to @training.team, notice: "Training is verwijderd."
    @training.destroy
  end

  private
    def set_team
      @team = if @training.present? && @training.team.present?
                @training.team
              else
                Team.find(params[:team_id])
              end
    end

    def create_training
      @training = if action_name == 'new'
                    @team.trainings.new
                  else
                    Training.new(training_params)
                  end
      @training.team = @team

      authorize @training
    end

    def set_training
      @training = Training.find(params[:id])
      authorize @training
    end

    def training_params
      params.require(:training).permit(:body, :remark, :team_id, :started_at, :ended_at, :start_time, :end_time)
    end

    def add_breadcrumbs
      add_breadcrumb "#{@training.team.name}", @training.team
      if @training.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb "Training", @training
      end
    end
end
