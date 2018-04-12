# frozen_string_literal: true

module Admin
  module ClubData
    class ResultsImportController < Admin::BaseController
      def new
        authorize Match
        ClubDataImporter.club_results
        ClubDataImporter.afgelastingen
        redirect_to admin_matches_path
      end
    end
  end
end
