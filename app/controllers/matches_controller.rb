# frozen_string_literal: true

class MatchesController < ApplicationController
  include SchedulesHelper

  before_action :set_team, only: [:new, :create]
  before_action :create_match, only: [:new, :create]
  before_action :set_match, only: [:show, :edit, :update, :destroy]
  before_action :set_team_for_show, only: [:show]
  before_action :add_breadcrumbs, only: [:show, :new, :edit]

  def show
    if policy(@match).show_presences? && @team.present?
      @presences = @match.find_or_create_presences(@team)&.asc
      @players = @presences&.present
    end
  end

  def new; end

  def create
    set_team_info if @team.present?

    if @match.save
      @match.teams << @team
      flash_message(:success, "Wedstrijd is toegevoegd.")
      redirect_to params[:return_url].presence || @team
    else
      render :new
    end
  end

  def edit; end

  def update
    if @match.update(match_params.merge(user_modified: true))
      flash_message(:success, "Wedstrijd is aangepast.")
      redirect_to params[:return_url].presence || @match
    else
      render "edit"
    end
  end

  def destroy
    @match.update(afgelast: true, afgelast_status: "Afgelast door #{current_user.name}")
    redirect_to @match, notice: "Wedstrijd is afgelast."
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
      @match = if action_name == "new"
                 Match.new(match_defaults)
               else
                 Match.new(match_defaults.merge(permitted_attributes(Match)))
               end
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
        edit_level: current_user.role?(:beheer_oefenwedstrijden) ? :beheer_oefenwedstrijden : :team_staff
      }
    end

    def set_match
      @match = Match.find(params[:id])
      authorize @match
    end

    def add_breadcrumbs
      [@team || @match.teams].flatten.each do |team|
        add_breadcrumb team.name, team
      end
      if @match.new_record?
        add_breadcrumb "Nieuw"
      else
        add_breadcrumb schedule_title(@match), @match
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
end
