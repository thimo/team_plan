class Admin::ClubData::CompetitionsImportController < AdminController
  def new
    authorize ClubDataCompetition
    ClubDataImporter.poule_standing_and_matches
    redirect_to admin_club_data_competitions_path
  end
end
