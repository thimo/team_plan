class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update]

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  private
    def set_team
      @team = Team.find(params[:id])
      authorize @team
    end
end
