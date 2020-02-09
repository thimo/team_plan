# frozen_string_literal: true

module ClubdataScheduler
  class PoulesJob < Que::Job
    include ClubdataJob

    def run
      Tenant.active.find_each do |tenant|
        ActsAsTenant.with_tenant(tenant) do
          next if skip_update?

          Season.active_season_for_today.competitions.active.each do |competition|
            # TODO: Implement counters/logging
            ClubdataImporter::PouleStandingJob.perform_later(tenant_id: tenant.id, competition_id: competition.id)
            ClubdataImporter::PouleMatchesJob.perform_later(tenant_id: tenant.id, competition_id: competition.id)
            ClubdataImporter::PouleResultsJob.perform_later(tenant_id: tenant.id, competition_id: competition.id)
          end
        end
      end
    end
  end
end
