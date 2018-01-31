class Admin::Knvb::ClubDataResultsImportController < AdminController
  def new
    authorize ClubDataMatch
    ClubDataImporter.club_results
    ClubDataImporter.afgelastingen
    redirect_to admin_club_data_matches_path
  end
end
