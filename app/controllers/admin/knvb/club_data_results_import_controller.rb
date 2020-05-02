module Admin
  module Knvb
    class ClubDataResultsImportController < Admin::BaseController
      def new
        authorize Match
        ClubdataScheduler::ResultsJob.enqueue
        ClubdataScheduler::CancelationsJob.enqueue
        flash_message(:success, "Import is ingepland.")
        redirect_to admin_knvb_matches_path
      end
    end
  end
end
