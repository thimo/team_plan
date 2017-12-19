class Org::BaseController < ApplicationController
  add_breadcrumb "Home", "/"
  before_action :admin_user
  before_action :default_breadcrumb

  def index
    authorize :org
    redirect_to org_positions_path
  end

  def show
    authorize :org
    redirect_to org_positions_path
  end

  private

    def admin_user
      permission_denied unless policy(:org).show?
    end

    def default_breadcrumb
      add_breadcrumb "Organisatie", org_path
    end
end
