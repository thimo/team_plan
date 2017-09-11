class Admin::ClubData::ResultsImportController < AdminController
  def new
    authorize ClubDataMatch
    ClubDataImporter.club_results
    redirect_to admin_club_data_matches_path
  end
end
