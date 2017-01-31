class Admin::MembersImportController < ApplicationController
  def new
    authorize(Member)
  end

  def create
    authorize(Member)
    Member.import(params[:file])

    redirect_to admin_members_path, notice: "Gebruikers zijn geïmporteerd."
  end
end
