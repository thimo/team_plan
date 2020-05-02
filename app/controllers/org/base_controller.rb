module Org
  class BaseController < ApplicationController
    add_breadcrumb "Home", "/"
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

      def default_breadcrumb
        add_breadcrumb "Organisatie", org_path
      end
  end
end
