# frozen_string_literal: true

module Admin
  module Knvb
    class CompetitionsImportController < Admin::BaseController
      def new
        authorize Competition
        Season.active_season_for_today.competitions.active.each do |competition|
          ClubdataImporter::PouleStandingJob.enqueue(tenant_id: ActsAsTenant.current_tenant.id,
                                                     competition_id: competition.id)
          ClubdataImporter::PouleMatchesJob.enqueue(tenant_id: ActsAsTenant.current_tenant.id,
                                                    competition_id: competition.id)
          ClubdataImporter::PouleResultsJob.enqueue(tenant_id: ActsAsTenant.current_tenant.id,
                                                    competition_id: competition.id)
        end
        flash_message(:success, "Import is ingepland.")
        redirect_to admin_knvb_competitions_path
      end
    end
  end
end
