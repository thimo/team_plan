class YearGroupBulkUpdatesController < ApplicationController
  before_action :set_season, only: [:new, :create]
  before_action :breadcumbs

  def new
  end

  def create
    year_groups = params[:year_groups]
    count = 0

    year_groups.each_line do |line|
      parts = line.split(',')
      unless parts[0].blank?
        year_group = @season.year_groups.build
        year_group.name = parts[0].strip
        year_group.year_of_birth_from = parts[1].to_i unless parts[1].blank?
        year_group.year_of_birth_to = parts[2].to_i unless parts[2].blank?
        year_group.save

        count += 1
      end
    end

    if count == 0
      flash[:alert] = "Er zijn geen jaargroepen aangemaakt"
    elsif count == 1
      flash[:success] = "Er is 1 jaargroep aangemaakt"
    else
      flash[:success] = "Er zijn #{count} jaargroepen aangemaakt"
    end

    redirect_to @season
  end

  private

    def set_season
      @season = Season.find(params[:season_id])
      authorize YearGroup
    end


    def breadcumbs
      add_breadcrumb "#{@season.name}", @season
      add_breadcrumb 'Nieuw'
    end
end
