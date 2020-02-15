# frozen_string_literal: true

module Admin
  module Knvb
    class ClubDataResultsImportController < Admin::BaseController
      def new
        authorize Match
        ClubdataImporter::ResultsJob.enqueue(tenant_id: ActsAsTenant.current_tenant.id)
        ClubdataImporter::CancelationsJob.enqueue(tenant_id: ActsAsTenant.current_tenant.id)
        flash_message(:success, "Import is ingepland.")
        redirect_to admin_knvb_matches_path
      end
    end
  end
end
