module Org
  class LocalTeamsController < Org::BaseController
    include SortHelper

    before_action :add_breadcrumbs

    def index
      authorize :org, :show_local_teams?

      @season = Season.active_season_for_today
      @teams = teams_hash

      params[:expand] ||= current_user.setting(:org_local_teams_expand)
      return if params[:expand].blank?

      current_user.set_setting(:org_local_teams_expand, params[:expand])

      @members_title = params[:expand]
      @team_members = members_per_team[params[:expand]]
    end

    private

      def add_breadcrumbs
        add_breadcrumb "Lokale teams"
      end

      # def team_staff_members
      #   policy_scope(TeamMember.for_season(Season.last)).active.staff
      # end

      def members
        @members ||= policy_scope(Member).active.with_local_teams.asc
      end

      def members_per_team
        @members_per_team ||= members.group_by(&:local_teams)
      end

      def teams_hash
        teams = members_per_team.keys.sort
        teams.each.map do |team|
          { value: team, label: team, count: members_per_team[team].size }
        end
      end
  end
end
