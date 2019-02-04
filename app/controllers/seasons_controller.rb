# frozen_string_literal: true

class SeasonsController < ApplicationController
  before_action :create_season, only: [:new, :create]
  before_action :set_season, only: [:show, :edit, :update, :destroy, :inherit_age_groups]
  before_action :add_breadcrumbs

  def index
    @seasons = policy_scope(Season).all.desc
  end

  def show
    @age_groups_male = policy_scope(@season.age_groups).male.asc
    @age_groups_female = policy_scope(@season.age_groups).female.asc
  end

  def new; end

  def create
    if @season.save
      redirect_to @season, notice: "Seizoen is toegevoegd."
    else
      render :new
    end
  end

  def edit; end

  def update
    old_status = @season.status

    if @season.update(permitted_attributes(@season))
      @season.transmit_status(@season.status, old_status)

      redirect_to @season, notice: "Seizoen is aangepast."
    else
      render "edit"
    end
  end

  def destroy
    @season.destroy
    redirect_to root_path, notice: "Seizoen is verwijderd."
  end

  def inherit_age_groups
    @season.inherit_age_groups

    flash_message(:success, "Leeftijdsgroepen zijn overgenomen van #{Season.active.first.name}")
    redirect_to @season
  end

  private

    def create_season
      @season = if action_name == "new"
                  start_year = Time.zone.today.year + (Time.zone.today.month >= 7 ? 1 : 0)
                  started_on = Time.zone.local(start_year, 7, 1)
                  ended_on = Time.zone.local(start_year + 1, 6, 30)
                  name = "#{start_year} / #{ended_on.year}"

                  Season.new(started_on: started_on, ended_on: ended_on, name:  name)
                else
                  Season.new(permitted_attributes(Season.new))
                end

      authorize @season
    end

    def set_season
      # Find season by id in params
      @season = Season.find(params[:id]) unless params[:id].nil?
      # Find first active season
      @season = Season.find_by(status: Season.statuses[:active]) if @season.nil?
      # Find first draft season
      @season = Season.find_by(status: Season.statuses[:draft]) if @season.nil?
      # Create a new draft season in the database
      @season = Season.create(name: "#{Time.zone.today.year} / #{Time.zone.today.year + 1}") if @season.nil?

      authorize @season
    end

    def add_breadcrumbs
      return if @season.nil?

      if @season.new_record?
        add_breadcrumb "Seizoenen", seasons_path
        add_breadcrumb "Nieuw"
      else
        add_breadcrumb @season.name, @season
      end
    end
end
