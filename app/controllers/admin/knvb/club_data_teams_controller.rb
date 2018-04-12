# frozen_string_literal: true

module Admin
  module Knvb
    class ClubDataTeamsController < Admin::BaseController
      def index
        @teams = policy_scope(ClubDataTeam).active.includes(:team).asc
      end
    end
  end
end
