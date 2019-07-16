# frozen_string_literal: true

module Org
  class SeasonsController < Org::BaseController
    before_action :set_season
    before_action :add_breadcrumbs

    def show; end

    private

      def set_season
        @season = policy_scope(Season).find(params[:id])
        authorize @season
      end

      def add_breadcrumbs
        add_breadcrumb "Seizoen #{@season.name}"
      end
  end
end
