class Admin::ClubData::TeamsImportController < Admin::BaseController
  def new
    authorize ClubDataTeam
    ClubDataImporter.teams_and_competitions
    redirect_to admin_club_data_teams_path
  end
end
