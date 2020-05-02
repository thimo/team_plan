class KeepersController < ApplicationController
  before_action :add_breadcrumbs

  def index
    @season = Season.active_season_for_today
    return if @season.nil?

    @age_groups_male = policy_scope(@season.age_groups).male.asc
    @age_groups_female = policy_scope(@season.age_groups).female.asc
  end

  private

    def add_breadcrumbs
      add_breadcrumb "Keepers", keepers_path
    end
end
