class Admin::ClubData::TeamPhotosImportController < ApplicationController
  def new
    authorize ClubDataTeam
    ClubDataImporter.team_photos
    redirect_to admin_club_data_teams_path
  end
end
