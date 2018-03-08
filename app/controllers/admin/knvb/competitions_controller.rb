class Admin::Knvb::CompetitionsController < Admin::BaseController
  def index
    @competitions = policy_scope(Competition).active.includes(:competitions_club_data_teams, :club_data_teams, club_data_teams: :team).asc
  end

  def show
    @competition = Competition.find(params[:id])
    authorize @competition
    @not_played_matches = @competition.matches.not_played.group_by{ |match| match.started_at.to_date }.sort_by{|date, matches| date}
    @played_matches = @competition.matches.played.group_by{ |match| match.started_at.to_date }.sort_by{|date, matches| date}
  end
end
