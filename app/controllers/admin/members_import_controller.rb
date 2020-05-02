module Admin
  class MembersImportController < Admin::BaseController
    before_action :add_breadcrumbs

    def new
      authorize(Member)
    end

    def create
      authorize(Member)

      encoding = params[:encoding] || "utf-8"
      current_user.set_setting("sportlink_members_encoding", encoding)

      if params[:file].nil?
        flash.now[:danger] = "Selecteer eerst een bestand."
        return render :new
      elsif !accepted_file?(params[:file])
        flash.now[:danger] = "Alleen CSV bestanden zoals je kunt downloaden uit Sportlink worden ondersteund."
        return render :new
      end

      @import_result = Member.import(params[:file], encoding)

      # After an import with at least one member, cleanup members that were last imported 7 days ago
      cleanup_after_import if @import_result[:counters][:imported].positive?
    end

    private

      def add_breadcrumbs
        add_breadcrumb "Leden", admin_members_path
        add_breadcrumb "Import"
      end

      def accepted_formats
        [".csv"]
      end

      def accepted_file?(file)
        file.content_type == "text/csv" || accepted_formats.include?(File.extname(file.original_filename).downcase)
      end

      def cleanup_after_import
        @cleanup_result = Member.cleanup(7.days.ago, @import_result[:member_ids])

        # Deactivate users with no matching members
        # TODO: this may not be needed as activating/de-activating is done on member import en user creation
        User.deactivate_for_inactive_members
        User.activate_for_active_members
      end
  end
end
