class SeasonsController < ApplicationController
  before_action :create_season, only: [:new, :create]
  before_action :set_season, only: [:show, :edit, :update, :destroy]
  before_action :breadcumbs

  def index
    @seasons = policy_scope(Season).all.desc
  end

  def show
    @age_groups_male = @season.age_groups.male.asc
    @age_groups_female = @season.age_groups.female.asc

    team_ids = current_user.teams_as_staff_in_season(@season).collect(&:id).uniq
    @open_team_evaluations = TeamEvaluation.open.where(team_id: team_ids)
  end

  def new; end

  def create
    if @season.save
      redirect_to @season, notice: 'Seizoen is toegevoegd.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @season.update_attributes(season_params)
      redirect_to @season, notice: 'Seizoen is aangepast.'
    else
      render 'edit'
    end
  end

  def destroy
    @season.destroy
    redirect_to seasons_path, notice: 'Seizoen is verwijderd.'
  end

  private

  def create_season
    @season = if action_name == 'new'
                Season.new
              else
                Season.new(season_params)
              end

    authorize @season
  end

  def set_season
    # Find season by id in params
    @season = Season.find(params[:id]) unless params[:id].nil?
    # Find first active season
    @season = Season.find_by(status: Season.statuses[:active]) if @season.nil?
    # Find first draft season
    @season = Season.find_by(status: Season.statuses[:draft]) if @season.nil?
    # Create a new draft season in the database
    @season = Season.create(name: "#{Time.current.year} / #{Time.current.year + 1}") if @season.nil?

    authorize @season
  end

  def breadcumbs
    unless @season.nil?
      if @season.new_record?
        add_breadcrumb 'Seizoenen', seasons_path
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb "#{@season.name}", @season
      end
    end
  end

  def season_params
    params.require(:season).permit(:name, :status)
  end
end
