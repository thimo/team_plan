# frozen_string_literal: true

module Admin
  class PlayBansImportController < Admin::BaseController
    before_action :add_breadcrumbs

    def new
      authorize(PlayBan)
    end

    def create
      # TODO: Process post
      # 1. check if all required params are there
      #    - if not display messages
      # 2. fetch members, process them and set messages
      # 3. ask for confirmation to process all
      authorize(PlayBan)

      if (message = validate_params).present?
        flash.now[:danger] = message
        render :new

      elsif params[:file].content_type != "text/csv"
        flash.now[:danger] = "Alleen CSV bestanden zoals je kunt downloaden uit Sportlink worden ondersteund."
        render :new

      else
        # @import_result = PlayBan.import(params[:file])
        #
        # # After an import with at least one member, cleanup members that were last imported 7 days ago
        # if @import_result[:counters][:imported].positive?
        #   @cleanup_result = PlayBan.cleanup(7.days.ago, @import_result[:member_ids])
        #
        #   # Deactivate users with no matching members
        #   # TODO: this may not be needed as activating/de-activating is done on member import en user creation
        #   User.deactivate_for_inactive_members
        #   User.activate_for_active_members
        # end

      end
    end

    private

      def add_breadcrumbs
        add_breadcrumb "Speelverboden", admin_play_bans_path
        add_breadcrumb "Import"
      end

      def validate_params
        return "Voer de KNVB nummers in" if params[:association_numbers].blank?
        return "Voer een datum in" if params[:date].blank?
      end
  end
end
