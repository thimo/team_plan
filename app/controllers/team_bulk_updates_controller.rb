class TeamBulkUpdatesController < ApplicationController
  before_action :set_year_group, only: [:new, :create]
  before_action :breadcumbs

  def new
  end

  def create
    teams = params[:teams]
    count = 0

    teams.each_line do |line|
      parts = line.split(',')
      unless parts[0].blank?
        team = @year_group.teams.build
        team.name = parts[0].strip
        team.save

        count += 1
      end
    end

    if count == 0
      flash[:alert] = "Er zijn geen teams aangemaakt"
    elsif count == 1
      flash[:success] = "Er is 1 team aangemaakt"
    else
      flash[:success] = "Er zijn #{count} teams aangemaakt"
    end

    redirect_to @year_group
  end

  private

    def set_year_group
      @year_group = YearGroup.find(params[:year_group_id])
      authorize Team
    end


    def breadcumbs
      add_breadcrumb @year_group.season.name.to_s, @year_group.season
      add_breadcrumb @year_group.name.to_s, @year_group
      add_breadcrumb 'Nieuw'
    end
  end
