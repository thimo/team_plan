# frozen_string_literal: true

module Scheduler
  module ClubData
    class ResultsJob < Que::Job
      def run
        Tenant.active.find_each do |tenant|
          ActsAsTenant.with_tenant(tenant) do
            next if skip_update?

            ClubData::ResultsJob.perform_later(tenant_id: tenant.id)
          end
        end
      end

      # TODO: re-use this method on other Queue jobs
      def skip_update?
        Season.active_season_for_today.nil? || Tenant.setting("clubdata_client_id").blank?
      end
    end
  end
end
