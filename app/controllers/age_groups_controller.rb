class AgeGroupsController < ApplicationController
  before_action :create_age_group, only: [:new, :create]
  before_action :set_age_group, only: [:show, :edit, :update]
  before_action :breadcumbs

  def show; end

  def new; end

  def create
    if @age_group.save
      redirect_to @age_group, notice: 'Jaargroep is toegevoegd.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @age_group.update_attributes(age_group_params)
      redirect_to @age_group, notice: 'Jaargroep is aangepast.'
    else
      render 'edit'
    end
  end

  private

  def create_age_group
    @age_group = if action_name == 'new'
                    AgeGroup.new
                  else
                    AgeGroup.new(age_group_params)
                  end
    authorize @age_group

    @season = Season.find(params[:season_id])
    @age_group.season = @season
  end

  def set_age_group
    @age_group = AgeGroup.find(params[:id])
    authorize @age_group
  end

  def breadcumbs
    add_breadcrumb "#{@age_group.season.name}", @age_group.season
    if @age_group.new_record?
      add_breadcrumb 'Nieuw'
    else
      add_breadcrumb @age_group.name.to_s, @age_group
    end
  end

  def age_group_params
    params.require(:age_group).permit(:name, :year_of_birth_from, :year_of_birth_to, :gender)
  end
end
