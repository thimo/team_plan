class TeamsController < ApplicationController
  before_action :create_team, only: [:new, :create]
  before_action :set_team, only: [:show, :edit, :update, :destroy]
  before_action :breadcumbs

  def show
    @commentable = @team

    @players = @team.team_members.player.asc.includes(:member).includes(:team)
    @staff = @team.team_members.staff.asc.includes(:member).includes(:team)

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

  def destroy
    redirect_to @team.age_group, notice: 'Team is verwijderd.'
    @team.destroy
  end

  private

  def create_team
    @age_group = AgeGroup.find(params[:age_group_id])

    @team = if action_name == 'new'
              @age_group.teams.new
            else
              Team.new(team_params)
            end
    authorize @team

    @team.age_group = @age_group
  end

  def set_team
    @team = Team.find(params[:id])
    authorize @team
  end

  def breadcumbs
    add_breadcrumb "#{@team.age_group.season.name}", @team.age_group.season
    add_breadcrumb @team.age_group.name, @team.age_group
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
