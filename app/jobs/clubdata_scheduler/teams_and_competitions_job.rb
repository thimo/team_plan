# frozen_string_literal: true

module ClubdataScheduler
  class TeamsAndCompetitionsJob < Que::Job
    include ClubdataJob

    def run
      Tenant.active.find_each do |tenant|
        next if tenant.skip_update?

        ClubdataImporter::TeamsAndCompetitionsJob.perform_later(tenant_id: tenant.id)
      end
    end
  end
end
