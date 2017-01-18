class SeasonsController < ApplicationController
  def index
    @seasons = policy_scope(Season).all.order(created_at: :desc)
  end

  def show
    if params[:id].nil?
      @season = Season.find_by(active: true)
    else
      @season = Season.find(params[:id])
    end
    
    authorize @season
    add_breadcrumb "#{@season.name}", @season
  end

  def new
  end

  def edit
  end
end
