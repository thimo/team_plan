class Admin::Knvb::ClubDataTeamPhotosImportController < Admin::BaseController
  def new
    authorize ClubDataTeam
    ClubDataImporter.team_photos
    redirect_to admin_knvb_club_data_teams_path
  end
end
