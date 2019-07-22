# frozen_string_literal: true

module Org
  class MembersController < Org::BaseController
    before_action :add_breadcrumbs

    def index
      @season = Season.active_season_for_today
      team_members = policy_scope(TeamMember.for_season(Season.last)).active.staff
      @team_members_per_role = team_members.group_by(&:role_i18n)
                                           .sort_by { |role, _tms| role }
      @groups = policy_scope(Group).asc
    end

    private

      def add_breadcrumbs
        add_breadcrumb "Actieve leden"
      end
  end
end
