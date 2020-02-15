# frozen_string_literal: true

module ClubdataScheduler
  class CancelationsJob < Que::Job
    include ClubdataJob

    def run
      Tenant.active.find_each do |tenant|
        next if tenant.skip_update?

        ClubdataImporter::CancelationsJob.enqueue(tenant_id: tenant.id)
      end
    end
  end
end
