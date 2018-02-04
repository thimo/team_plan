class Admin::BaseController < ApplicationController
  add_breadcrumb "Home", "/"
  before_action :admin_user
  before_action :default_breadcrumb

  def index
    authorize :admin
    redirect_to admin_members_path
  end

  def show
    authorize :admin
    redirect_to admin_members_path
  end

  private

    def admin_user
      permission_denied unless policy(:admin).show?
    end

    def default_breadcrumb
      add_breadcrumb "Admin", admin_path
    end
end
