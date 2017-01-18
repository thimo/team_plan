class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update]

  def show
    @commentable = @team
    @comments = @commentable.comments
    @comment = Comment.new
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

      add_breadcrumb "#{@team.year_group.season.name}", @team.year_group.season
      add_breadcrumb "#{@team.year_group.name}", @team.year_group
      add_breadcrumb "#{@team.name}", @team
    end
end
