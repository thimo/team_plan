class Admin::MembersImportController < Admin::BaseController
  before_action :add_breadcrumbs

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
      @import_result = Member.import(params[:file])

      # After an import with at least one member, cleanup members that were last imported 7 days ago
      if @import_result[:counters][:imported] > 0
        @cleanup_result = Member.cleanup(7.days.ago)

        # Deactivate users with no matching members
        User.deactivate_for_inactive_members
      end

    end
  end

  private

    def add_breadcrumbs
      add_breadcrumb 'Leden', admin_members_path
    end

end
