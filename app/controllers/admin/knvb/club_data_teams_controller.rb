# frozen_string_literal: true

module Admin
  module Knvb
    class ClubDataTeamsController < Admin::BaseController
      def index
        @teams = policy_scope(Season.active_season_for_today.club_data_teams).active.includes(:teams).asc
      end
    end
  end
end
