class Admin::MembersImportController < AdminController
  def new
    authorize(Member)

    add_breadcrumb 'Leden', admin_members_path
    add_breadcrumb "Import"
  end

  def create
    authorize(Member)
    Member.import(params[:file])

    redirect_to admin_members_path, notice: "Gebruikers zijn geïmporteerd."
  end
end
