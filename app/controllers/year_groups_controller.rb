class YearGroupsController < ApplicationController
  before_action :set_year_group, only: [:show, :edit, :update]

  def show
    add_breadcrumb "#{@year_group.season.name}", @year_group.season
    add_breadcrumb "#{@year_group.name}", @year_group
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
    def set_year_group
      @year_group = YearGroup.find(params[:id])
      authorize @year_group
    end
end
