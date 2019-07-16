# frozen_string_literal: true

module Org
  class BaseController < ApplicationController
    add_breadcrumb "Home", "/"
    before_action :admin_user # TODO: remove this, should be more open
    before_action :default_breadcrumb

    def index
      authorize :org
      redirect_to org_members_path
    end

    def show
      authorize :org
      redirect_to org_members_path
    end

    private

      def admin_user
        permission_denied unless policy(:org).show?
      end

      def default_breadcrumb
        add_breadcrumb "Organisatie", org_path
      end
  end
end
