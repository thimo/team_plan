class Admin::Knvb::ClubDataCompetitionsImportController < Admin::BaseController
  def new
    authorize ClubDataCompetition
    ClubDataImporter.poules
    redirect_to admin_knvb_club_data_competitions_path
  end
end
