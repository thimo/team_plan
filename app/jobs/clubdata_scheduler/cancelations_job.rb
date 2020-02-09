# frozen_string_literal: true

module ClubdataScheduler
  class CancelationsJob < Que::Job
    include ClubdataJob

    def run
      Tenant.active.find_each do |tenant|
        ActsAsTenant.with_tenant(tenant) do
          next if skip_update?

          ClubdataImporter::CancelationsJob.perform_later(tenant_id: tenant.id)
        end
      end
    end
  end
end
