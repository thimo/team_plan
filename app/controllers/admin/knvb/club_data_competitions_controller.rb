class Admin::Knvb::CompetitionsController < Admin::BaseController
  def index
    @competitions = policy_scope(Competition).active.includes(:clubdatacompetitions_club_data_teams, :club_data_teams).asc
  end

  def show
    @competition = Competition.find(params[:id])
    authorize @competition
    @matches = @competition.matches.asc
  end
end
