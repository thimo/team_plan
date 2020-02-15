class ScheduleRefereeImportJob < Que::Job
  def run
    Tenant.active.find_each do |tenant|
      next if tenant.skip_update?

      RefereeImportJob.enqueue(tenant_id: tenant.id)
    end
  end
end
