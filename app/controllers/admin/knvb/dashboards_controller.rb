module Admin
  module Knvb
    class DashboardsController < Admin::BaseController
      before_action :add_breadcrumbs

      def index
        authorize :club_data_dashboard, :index?
        skip_policy_scope
      end

      private

        def add_breadcrumbs
          add_breadcrumb "KNVB", admin_knvb_club_data_teams_path
          add_breadcrumb "Dashboard"
        end
    end
  end
end
