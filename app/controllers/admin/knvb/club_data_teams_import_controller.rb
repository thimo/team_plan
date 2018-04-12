# frozen_string_literal: true

module Admin
  module Knvb
    class ClubDataTeamsImportController < Admin::BaseController
      def new
        authorize ClubDataTeam
        ClubDataImporter.teams_and_competitions
        redirect_to admin_knvb_club_data_teams_path
      end
    end
  end
end
