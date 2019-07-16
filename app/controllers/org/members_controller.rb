# frozen_string_literal: true

module Org
  class MembersController < Org::BaseController
    before_action :add_breadcrumbs

    def index
      skip_policy_scope
      # TODO: Get
      # - active season for age_groups, teams, team_members
      # - all groups
    end

    private

      def add_breadcrumbs
        add_breadcrumb "Vrijwilligers"
      end
  end
end
