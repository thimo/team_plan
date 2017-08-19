class Admin::ClubData::CompetitionsController < ApplicationController
  def index
    @competitions = policy_scope(ClubDataCompetition).active.asc
  end

  def show
    @competition = ClubDataCompetition.find(params[:id])
    authorize @competition
    @matches = @competition.club_data_matches.asc
  end
end
