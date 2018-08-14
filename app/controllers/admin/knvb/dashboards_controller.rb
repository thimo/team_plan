# frozen_string_literal: true

module Admin
  module Knvb
    class ClubDataDashboardsController < Admin::BaseController
      before_action :add_breadcrumbs

      def index
        authorize :club_data_dashboard, :index?
        skip_policy_scope
      end

      private

        def add_breadcrumbs
          add_breadcrumb "KNVB"
          add_breadcrumb "Dashboard"
        end
    end
  end
end
