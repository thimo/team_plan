# frozen_string_literal: true

module ClubdataScheduler
  class PoulesJob < Que::Job
    include ClubdataJob

    def run
      Tenant.active.find_each do |tenant|
        next if tenant.skip_update?

        ActsAsTenant.with_tenant(tenant) do
          schedule_season_jobs
        end
      end
    end

    def schedule_season_jobs
      Season.active_season_for_today.competitions.active.each do |competition|
        schedule_competition_jobs(tenant_id, competition.id)
      end
    end

    def schedule_competition_jobs(tenant_id, competition_id)
      ClubdataImporter::PouleStandingJob.enqueue(tenant_id: tenant_id, competition_id: competition_id)
      ClubdataImporter::PouleMatchesJob.enqueue(tenant_id: tenant_id, competition_id: competition_id)
      ClubdataImporter::PouleResultsJob.enqueue(tenant_id: tenant_id, competition_id: competition_id)
    end
  end
end
