# frozen_string_literal: true

module Scheduler
  class ClubDataResultsJob < Que::Job
    include ClubDataJob

    def run
      Tenant.active.find_each do |tenant|
        ActsAsTenant.with_tenant(tenant) do
          next if skip_update?

          ClubData::ResultsJob.perform_later(tenant_id: tenant.id)
        end
      end
    end
  end
end
