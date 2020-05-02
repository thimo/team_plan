module Admin
  module Knvb
    class ClubDataTeamPhotosImportController < Admin::BaseController
      def new
        authorize ClubDataTeam
        ClubdataScheduler::TeamPhotosJob.enqueue
        flash_message(:success, "Import is ingepland.")
        redirect_to admin_knvb_club_data_teams_path
      end
    end
  end
end
