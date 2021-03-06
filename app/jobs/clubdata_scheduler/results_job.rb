module ClubdataScheduler
  class ResultsJob < Que::Job
    include ClubdataJob

    def run
      Tenant.active.find_each do |tenant|
        next if tenant.skip_update?

        ClubdataImporter::ResultsJob.enqueue(tenant_id: tenant.id)
      end
    end
  end
end
