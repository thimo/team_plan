# frozen_string_literal: true

class AgeGroupBulkUpdatesController < ApplicationController
  before_action :set_season, only: [:new, :create]
  before_action :add_breadcrumbs

  def new; end

  def create
    age_groups = params[:age_groups]
    count = 0

    age_groups.each_line do |line|
      parts = line.split(",")
      next if parts[0].blank?

      age_group = @season.age_groups.build
      age_group.name = parts[0].strip
      age_group.year_of_birth_from = parts[1].to_i if parts[1].present?
      age_group.year_of_birth_to = parts[2].to_i if parts[2].present?
      age_group.gender = parts[3].strip.downcase if parts[3].present?
      age_group.save

      count += 1
    end

    if count.zero?
      flash_message(:alert, "Er zijn geen leeftijdsgroepen aangemaakt")
    elsif count.one?
      flash_message(:success, "Er is één leeftijdsgroep aangemaakt")
    else
      flash_message(:success, "Er zijn #{count} leeftijdsgroepen aangemaakt")
    end

    redirect_to @season
  end

  private

    def set_season
      @season = Season.find(params[:season_id])
      authorize AgeGroup.new(season: @season)
    end

    def add_breadcrumbs
      add_breadcrumb @season.name.to_s, @season
      add_breadcrumb "Nieuw"
    end
end
