# frozen_string_literal: true

module Admin
  module Knvb
    class ClubDataTeamsController < Admin::BaseController
      before_action :add_breadcrumbs

      def index
        @teams = policy_scope(Season.active_season_for_today.club_data_teams).active.includes(:teams).asc
      end

      private

        def add_breadcrumbs
          add_breadcrumb "KNVB", admin_knvb_club_data_teams_path
          add_breadcrumb "Teams"
        end
    end
  end
end
