class CompetitionsController < ApplicationController
  before_action :set_competition, only: [:show]
  before_action :add_breadcrumbs

  def show
    matches = policy_scope(@competition.matches)
    @not_played_matches = matches.not_played.asc.group_by(&:wedstrijddatum_date)
    @played_matches = matches.played.desc.group_by(&:wedstrijddatum_date)
  end

  private

  def set_competition
    @competition = Competition.find(params[:id])
    authorize @competition
  end

  def add_breadcrumbs
    @competition.teams.each do |team|
      add_breadcrumb team.name_with_club, team
    end
    add_breadcrumb "#{t @competition.competitiesoort} - #{@competition.klasse}"
  end
end
