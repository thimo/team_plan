class SeasonsController < ApplicationController
  def index
    @seasons = policy_scope(Season)
  end

  def show
    @season = Season.find(params[:id])
  end

  def new
  end

  def edit
  end
end
