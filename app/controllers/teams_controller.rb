class TeamsController < ApplicationController
  before_action :create_team, only: [:new, :create]
  before_action :set_team, only: [:show, :edit, :update]
  before_action :breadcumbs

  def show
    @commentable = @team

    @players = @team.players.asc
    @coaches = @team.coaches.asc
    @trainers = @team.trainers.asc
    @team_parents = @team.team_parents.asc

    @comments = @commentable.comments.includes(:user)
    @comment = Comment.new
  end

  def new; end

  def create
    if @team.save
      redirect_to @team, notice: 'Team is toegevoegd.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @team.update_attributes(team_params)
      redirect_to @team, notice: 'Team is aangepast.'
    else
      render 'edit'
    end
  end

  private

  def create_team
    @team = if action_name == 'new'
              Team.new
            else
              Team.new(team_params)
            end
    authorize @team

    @year_group = YearGroup.find(params[:year_group_id])
    @team.year_group = @year_group
  end

  def set_team
    @team = Team.find(params[:id])
    authorize @team
  end

  def breadcumbs
    add_breadcrumb "Seizoen #{@team.year_group.season.name}", @team.year_group.season
    add_breadcrumb @team.year_group.name, @team.year_group
    if @team.new_record?
      add_breadcrumb 'Nieuw'
    else
      add_breadcrumb @team.name, @team
    end
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
