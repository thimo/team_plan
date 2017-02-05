class AgeGroupBulkUpdatesController < ApplicationController
  before_action :set_season, only: [:new, :create]
  before_action :breadcumbs

  def new
  end

  def create
    age_groups = params[:age_groups]
    count = 0

    age_groups.each_line do |line|
      parts = line.split(',')
      unless parts[0].blank?
        age_group = @season.age_groups.build
        age_group.name = parts[0].strip
        age_group.year_of_birth_from = parts[1].to_i unless parts[1].blank?
        age_group.year_of_birth_to = parts[2].to_i unless parts[2].blank?
        age_group.gender = parts[3] unless parts[3].blank?
        age_group.save

        count += 1
      end
    end

    if count == 0
      flash[:alert] = "Er zijn geen leeftijdsgroepen aangemaakt"
    elsif count == 1
      flash[:success] = "Er is 1 leeftijdsgroep aangemaakt"
    else
      flash[:success] = "Er zijn #{count} leeftijdsgroepen aangemaakt"
    end

    redirect_to @season
  end

  private

    def set_season
      @season = Season.find(params[:season_id])
      authorize AgeGroup
    end


    def breadcumbs
      add_breadcrumb "#{@season.name}", @season
      add_breadcrumb 'Nieuw'
    end
end
