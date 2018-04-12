# frozen_string_literal: true

module Admin
  module Knvb
    class CompetitionsImportController < Admin::BaseController
      def new
        authorize Competition
        ClubDataImporter.poules
        redirect_to admin_knvb_competitions_path
      end
    end
  end
end
