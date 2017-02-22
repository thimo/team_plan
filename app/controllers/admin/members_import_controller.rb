class Admin::MembersImportController < AdminController
  def new
    authorize(Member)

    add_breadcrumb 'Leden', admin_members_path
    add_breadcrumb "Import"
  end

  def create
    authorize(Member)

    if params[:file].nil?
      flash[:danger] = "Selecteer eerst een bestand."
      render :new

    elsif params[:file].content_type != "text/csv"
      flash[:danger] = "Alleen CSV bestanden zoals je kunt downloaden uit Sportlink worden ondersteund."
      render :new

    else
      Member.import(params[:file])

      redirect_to admin_members_path, notice: "De gebruikers zijn geïmporteerd."
    end
  end
end
