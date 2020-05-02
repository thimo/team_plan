module Admin
  module Knvb
    class CompetitionsController < Admin::BaseController
      before_action :add_breadcrumbs
      before_action :set_competition, only: [:show, :destroy]

      def index
        @competitions = policy_scope(Season.active_season_for_today.competitions).active
                                                                                 .includes(:club_data_team_competitions,
                                                                                           :club_data_teams,
                                                                                           club_data_teams: :teams).asc
        authorize @competitions
      end

      def show
        @not_played_matches = @competition.matches.not_played.group_by { |match| match.started_at.to_date }
                                          .sort_by { |date, _matches| date }
        @played_matches = @competition.matches.played.group_by { |match| match.started_at.to_date }
                                      .sort_by { |date, _matches| date }
      end

      def destroy
        redirect_to admin_knvb_competitions_path, notice: "Competitie is verwijderd."
        @competition.destroy
      end

      private

        def add_breadcrumbs
          add_breadcrumb "KNVB", admin_knvb_club_data_teams_path
          add_breadcrumb "Competities", admin_knvb_competitions_path
        end

        def set_competition
          @competition = Competition.find(params[:id])
          authorize @competition
        end
    end
  end
end
