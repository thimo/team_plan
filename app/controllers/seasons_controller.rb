class SeasonsController < ApplicationController
  before_action :create_season, only: [:new, :create]
  before_action :set_season, only: [:show, :edit, :update, :destroy]
  before_action :breadcumbs

  def index
    @seasons = policy_scope(Season).all.desc
  end

  def show
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
    @season = if params[:id].nil?
                Season.find_by(status: Season.statuses[:active])
              else
                Season.find(params[:id])
              end

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
