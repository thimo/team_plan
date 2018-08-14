# frozen_string_literal: true

module Admin
  module Knvb
    class LogsController < Admin::BaseController
      before_action :add_breadcrumbs

      def index
        @logs = policy_scope(ClubDataLog).desc.page(params[:page]).per(50)
      end

      private

        def add_breadcrumbs
          add_breadcrumb "KNVB"
          add_breadcrumb "Import Logs"
        end
    end
  end
end
