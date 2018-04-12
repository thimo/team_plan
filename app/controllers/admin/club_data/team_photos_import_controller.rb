# frozen_string_literal: true

module Admin
  module ClubData
    class TeamPhotosImportController < Admin::BaseController
      def new
        authorize ClubDataTeam
        ClubDataImporter.team_photos
        redirect_to admin_club_data_teams_path
      end
    end
  end
end
