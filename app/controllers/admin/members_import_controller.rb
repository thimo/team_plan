# frozen_string_literal: true

module Admin
  class MembersImportController < Admin::BaseController
    before_action :add_breadcrumbs

    def new
      authorize(Member)
    end

    def create
      authorize(Member)

      if params[:file].nil?
        flash.now[:danger] = "Selecteer eerst een bestand."
        render :new

      elsif params[:file].content_type != "text/csv"
        flash.now[:danger] = "Alleen CSV bestanden zoals je kunt downloaden uit Sportlink worden ondersteund."
        render :new

      else
        @import_result = Member.import(params[:file])

        # After an import with at least one member, cleanup members that were last imported 7 days ago
        if @import_result[:counters][:imported].positive?
          @cleanup_result = Member.cleanup(7.days.ago, @import_result[:member_ids])

          # Deactivate users with no matching members
          # TODO: this may not be needed as activating/de-activating is done on member import en user creation
          User.deactivate_for_inactive_members
          User.activate_for_active_members
        end

      end
    end

    private

      def add_breadcrumbs
        add_breadcrumb "Leden", admin_members_path
        add_breadcrumb "Import"
      end
  end
end
