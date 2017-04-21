class AgeGroupsController < ApplicationController
  include SortHelper

  before_action :create_age_group, only: [:new, :create]
  before_action :set_age_group, only: [:show, :edit, :update, :destroy]
  before_action :breadcumbs

  def show
    @open_team_evaluations = TeamEvaluation.open.by_age_group(@age_group).asc
    @finished_team_evaluations = TeamEvaluation.finished.desc_finished.by_age_group(@age_group)
    @teams = human_sort(@age_group.teams, :name)
  end

  def new; end

  def create
    if @age_group.save
      redirect_to @age_group, notice: 'Leeftijdsgroep is toegevoegd.'
    else
      render :new
    end
  end

  def edit; end

  def update
    old_status = @age_group.status

    if @age_group.update_attributes(permitted_attributes(@age_group))
      @age_group.transmit_status(@age_group.status, old_status)

      redirect_to @age_group, notice: 'Leeftijdsgroep is aangepast.'
    else
      render 'edit'
    end
  end

  def destroy
    redirect_to @age_group.season, notice: 'Leeftijdsgroep is verwijderd.'
    @age_group.destroy
  end

  private

    def create_age_group
      @season = Season.find(params[:season_id])

      @age_group = if action_name == 'new'
                      @season.age_groups.new
                    else
                      AgeGroup.new(permitted_attributes(@age_group))
                    end
      @age_group.season = @season

      authorize @age_group
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

    # def age_group_params
    #   params.require(:age_group).permit(:name, :year_of_birth_from, :year_of_birth_to, :gender)
    #   # :status if policy change status
    # end
end
