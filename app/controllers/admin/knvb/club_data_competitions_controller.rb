class Admin::Knvb::ClubDataCompetitionsController < AdminController
  def index
    @competitions = policy_scope(ClubDataCompetition).active.includes(:clubdatacompetitions_club_data_teams, :club_data_teams).asc
  end

  def show
    @competition = ClubDataCompetition.find(params[:id])
    authorize @competition
    @matches = @competition.club_data_matches.asc
  end
end
