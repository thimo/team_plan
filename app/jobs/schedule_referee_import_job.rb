class ScheduleRefereeImportJob < Que::Job
  def run
    Tenant.active.find_each do |tenant|
      next if tenant.skip_update?

      RefereeImportJob.perform_later(tenant_id: tenant.id)
    end
  end
end
