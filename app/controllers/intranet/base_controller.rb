module Intranet
  class BaseController < ApplicationController
    add_breadcrumb "Home", "/"
    before_action :admin_user # TODO: remove this, should be more open
    before_action :default_breadcrumb

    def index
      authorize :intranet
      redirect_to intranet_files_path
    end

    def show
      authorize :intranet
      redirect_to intranet_files_path
    end

    private

      def admin_user
        permission_denied unless policy(:intranet).show?
      end

      def default_breadcrumb
        add_breadcrumb "Intranet", intranet_path
      end
  end
end
