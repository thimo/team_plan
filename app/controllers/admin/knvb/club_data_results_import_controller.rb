class Admin::Knvb::ClubDataResultsImportController < Admin::BaseController
  def new
    authorize ClubDataMatch
    ClubDataImporter.club_results
    ClubDataImporter.afgelastingen
    redirect_to admin_knvb_club_data_matches_path
  end
end
