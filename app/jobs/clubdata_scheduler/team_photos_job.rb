# frozen_string_literal: true

module ClubdataScheduler
  class TeamPhotosJob < Que::Job
    include ClubdataJob

    def run
      Tenant.active.find_each do |tenant|
        next if tenant.skip_update?

        ActsAsTenant.with_tenant(tenant) do
          Season.active_season_for_today.club_data_teams.active.each do |club_data_team|
            ClubdataImporter::TeamPhotosJob.enqueue(tenant_id: tenant.id, club_data_team_id: club_data_team.id)
          end
        end
      end
    end
  end
end
