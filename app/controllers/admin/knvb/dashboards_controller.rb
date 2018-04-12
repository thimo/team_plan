# frozen_string_literal: true

module Admin
  module Knvb
    class ClubDataDashboardsController < Admin::BaseController
      def index
        authorize :club_data_dashboard, :index?
        skip_policy_scope
      end
    end
  end
end
