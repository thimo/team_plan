class Admin::Knvb::ClubDataResultsImportController < Admin::BaseController
  def new
    authorize Match
    ClubDataImporter.club_results
    ClubDataImporter.afgelastingen
    redirect_to admin_knvb_matches_path
  end
end
