# frozen_string_literal: true

class MatchesController < ApplicationController
  include SchedulesHelper

  before_action :set_team, only: [:new, :create]
  before_action :create_match, only: [:new, :create]
  before_action :set_match, only: [:show, :edit, :update, :destroy]
  before_action :set_team_for_show, only: [:show]
  before_action :add_breadcrumbs

  def show
    set_active_tab

    set_presences_and_players
  end

  def new; end

  def create
    @match.attributes = permitted_attributes(@match).merge(user_modified: true)
    @match.is_home_match = false if @match.toernooi?

    set_team_info if @team.present?

    if params[:refresh_only].blank? && @match.save
      @match.teams << @team if @match.teams.find_by(id: @team).blank?
      flash_message(:success, "#{@match.type_name.capitalize} is toegevoegd.")
      redirect_to params[:return_url].presence || @team
    else
      render :new
    end
  end

  def edit; end

  def update
    @match.attributes = permitted_attributes(@match).merge(user_modified: true)
    @match.is_home_match = false if @match.toernooi?

    if params[:refresh_only].blank? && @match.save
      flash_message(:success, "#{@match.type_name.capitalize} is aangepast.")
      redirect_to params[:return_url].presence || @match
    else
      render "edit"
    end
  end

  def destroy
    if @match.team_staff? && current_user.team_staff_for?(@match)
      redirect_to @match.teams.first, notice: "#{@match.type_name.capitalize} is verwijderd."
      @match.destroy
    else
      @match.update(afgelast: true, afgelast_status: "Afgelast door #{current_user.name}")
      redirect_to @match, notice: "#{@match.type_name.capitalize} is afgelast."
    end
  end

  private

    def set_team
      @team = Team.find(params[:team_id]) if params[:team_id].present?
    end

    def set_team_for_show
      @team = Team.find(params[:team]) if params[:team]
      @team ||= @match.teams.first if @match.teams.size == 1
    end

    def create_match
      @match = Match.new(match_defaults)
      @match.teams << @team if @team.present?
      authorize @match
    end

    def match_defaults
      {
        wedstrijddatum: Match.new_match_datetime,
        competition: Competition.custom.asc.first,
        user_modified: true,
        eigenteam: true,
        created_by: current_user,
        edit_level: current_user.role?(Role::BEHEER_OEFENWEDSTRIJDEN) ? :beheer_oefenwedstrijden : :team_staff
      }
    end

    def set_match
      @match = Match.find(params[:id])
      authorize @match
    end

    def add_breadcrumbs
      [@team || @match.teams].flatten.each do |team|
        add_breadcrumb team.name_with_club, team
      end
      if @match.knvb?
        add_breadcrumb @match.competition.competitienaam, @match.competition
      end
      if @match.new_record?
        add_breadcrumb "Nieuw"
      else
        add_breadcrumb @match.title, @match
      end
    end

    def set_team_info
      @match.thuisteamid = nil
      @match.uitteamid   = nil

      if @match.is_home_match == "true"
        @match.thuisteam   = @team.name_with_club
        @match.uitteam     = @match.opponent
      else
        @match.thuisteam   = @match.opponent
        @match.uitteam     = @team.name_with_club
      end
    end

    def set_presences_and_players
      return unless policy(@match).show_presences?

      team = (@match.teams & current_user.teams_as_staff).first
      return if team.blank?

      @presences = @match.find_or_create_presences(team).asc
      @players = @presences.present
    end

    def set_active_tab
      @active_tab = params[:tab].presence || current_user.setting(:active_match_tab).presence || "match"
      @active_tab = "match" unless policy(@match).try("show_#{@active_tab}?")
      current_user.set_setting(:active_match_tab, @active_tab)
    end
end
