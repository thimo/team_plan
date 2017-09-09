class CompetitionsController < ApplicationController
  before_action :set_competition, only: [:show]
  before_action :add_breadcrumbs

  def show
  end

  private

    def set_competition
      @competition = ClubDataCompetition.find(params[:id])
      authorize @competition
    end

    def add_breadcrumbs
      @competition.club_data_teams.map(&:team).each do |team|
        add_breadcrumb team.name, team
      end
      add_breadcrumb "#{@competition.competitiesoort} - #{@competition.klasse}"
    end
end
