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
      result = Member.import(params[:file])

      # After an import with at least one member, cleanup members that were last imported 7 days ago
      if result[:counters][:imported] > 0
        Member.cleanup(7.days.ago)
      end

      redirect_to admin_members_path, notice: "#{result[:counters][:imported]} gebruikers zijn geïmporteerd waarvan #{result[:counters][:created]} nieuw, #{result[:counters][:changed]} aangepast."
    end
  end
end
