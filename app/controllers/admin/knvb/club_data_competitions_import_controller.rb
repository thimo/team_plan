class Admin::Knvb::CompetitionsImportController < Admin::BaseController
  def new
    authorize Competition
    ClubDataImporter.poules
    redirect_to admin_knvb_competitions_path
  end
end
