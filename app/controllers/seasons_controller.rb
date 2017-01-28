class SeasonsController < ApplicationController
  before_action :create_season, only: [:new, :create]
  before_action :set_season, only: [:show, :edit, :update]
  before_action :breadcumbs

  def index
    @seasons = policy_scope(Season).all.order(created_at: :desc)
  end

  def show
    add_breadcrumb @season.name.to_s, @season
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
                Season.find_by(active: true)
              else
                Season.find(params[:id])
              end

    authorize @season
  end

  def breadcumbs
    unless @season.nil?
      if @season.new_record?
        add_breadcrumb 'Nieuw'
      else
        add_breadcrumb @season.name.to_s, @season
      end
    end
  end

  def season_params
    params.require(:season).permit(:name, :active)
  end
end
