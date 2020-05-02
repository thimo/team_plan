module Admin
  module Knvb
    class CompetitionsImportController < Admin::BaseController
      def new
        authorize Competition
        ClubdataScheduler::PoulesJob.enqueue
        flash_message(:success, "Import is ingepland.")
        redirect_to admin_knvb_competitions_path
      end
    end
  end
end
