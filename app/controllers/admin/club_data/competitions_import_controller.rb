class Admin::ClubData::CompetitionsImportController < AdminController
  def new
    authorize ClubDataCompetition
    ClubDataImporter.poules
    redirect_to admin_club_data_competitions_path
  end
end
