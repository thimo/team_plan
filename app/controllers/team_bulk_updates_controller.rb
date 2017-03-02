class TeamBulkUpdatesController < ApplicationController
  before_action :set_age_group, only: [:new, :create]
  before_action :breadcumbs

  def new
  end

  def create
    teams = params[:teams]
    count = 0

    teams.each_line do |line|
      parts = line.split(',')
      unless parts[0].blank?
        team = @age_group.teams.build
        team.name = parts[0].strip
        team.save

        count += 1
      end
    end

    if count == 0
      flash[:alert] = "Er zijn geen teams aangemaakt"
    elsif count == 1
      flash[:success] = "Er is één team aangemaakt"
    else
      flash[:success] = "Er zijn #{count} teams aangemaakt"
    end

    redirect_to @age_group
  end

  private

    def set_age_group
      @age_group = AgeGroup.find(params[:age_group_id])
      authorize Team.new(age_group: @age_group)
    end


    def breadcumbs
      add_breadcrumb "#{@age_group.season.name}", @age_group.season
      add_breadcrumb @age_group.name, @age_group
      add_breadcrumb 'Nieuw'
    end
  end
