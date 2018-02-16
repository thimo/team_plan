class Admin::ClubData::CompetitionsImportController < Admin::BaseController
  def new
    authorize Competition
    ClubDataImporter.poule_standings
    ClubDataImporter.poule_matches
    ClubDataImporter.poule_results
    redirect_to admin_competitions_path
  end
end
