module Admin
  module Knvb
    class MatchesController < Admin::BaseController
      before_action :add_breadcrumbs

      def index
        @not_played_matches = policy_scope(Match).own.not_played.asc
                                                 .in_period(0.days.ago.beginning_of_day, 1.week.from_now.end_of_day)
                                                 .includes([:competition])
                                                 .group_by { |match| match.wedstrijddatum.to_date }
        @played_matches = policy_scope(Match).own.played.desc
                                             .in_period(1.week.ago.end_of_day, 0.days.from_now.end_of_day)
                                             .includes([:competition])
                                             .group_by { |match| match.wedstrijddatum.to_date }
        authorize Match
      end

      private

        def add_breadcrumbs
          add_breadcrumb "KNVB", admin_knvb_club_data_teams_path
          add_breadcrumb "Wedstrijden", admin_knvb_matches_path
        end
    end
  end
end
