class YearGroupsController < ApplicationController
  before_action :create_year_group, only: [:new, :create]
  before_action :set_year_group, only: [:show, :edit, :update]
  before_action :breadcumbs

  def show; end

  def new; end

  def create
    if @year_group.save
      redirect_to @year_group, notice: 'Jaargroep is toegevoegd.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @year_group.update_attributes(year_group_params)
      redirect_to @year_group, notice: 'Jaargroep is aangepast.'
    else
      render 'edit'
    end
  end

  private

  def create_year_group
    @year_group = if action_name == 'new'
                    YearGroup.new
                  else
                    YearGroup.new(year_group_params)
                  end
    authorize @year_group

    @season = Season.find(params[:season_id])
    @year_group.season = @season
  end

  def set_year_group
    @year_group = YearGroup.find(params[:id])
    authorize @year_group
  end

  def breadcumbs
    add_breadcrumb "#{@year_group.season.name}", @year_group.season
    if @year_group.new_record?
      add_breadcrumb 'Nieuw'
    else
      add_breadcrumb @year_group.name.to_s, @year_group
    end
  end

  def year_group_params
    params.require(:year_group).permit(:name, :year_of_birth_from, :year_of_birth_to)
  end
end
