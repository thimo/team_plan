class Admin::ClubData::CompetitionsImportController < AdminController
  def new
    authorize ClubDataCompetition
    ClubDataImporter.poule_standings
    ClubDataImporter.poule_matches
    ClubDataImporter.poule_results
    redirect_to admin_club_data_competitions_path
  end
end
