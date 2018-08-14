# frozen_string_literal: true

module Admin
  module Knvb
    class CompetitionsController < Admin::BaseController
      before_action :add_breadcrumbs

      def index
        @competitions = policy_scope(Season.active_season_for_today.competitions).active.includes(:club_data_team_competitions, :club_data_teams,
                                                                  club_data_teams: :teams).asc
      end

      def show
        @competition = Competition.find(params[:id])
        authorize @competition
        @not_played_matches = @competition.matches.not_played.group_by { |match| match.started_at.to_date }
                                          .sort_by { |date, matches| date }
        @played_matches = @competition.matches.played.group_by { |match| match.started_at.to_date }
                                      .sort_by { |date, matches| date }
      end

      private

        def add_breadcrumbs
          add_breadcrumb "KNVB"
          add_breadcrumb "Competities"
        end
    end
  end
end
