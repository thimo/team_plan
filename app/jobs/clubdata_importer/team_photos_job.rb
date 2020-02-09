# frozen_string_literal: true

module ClubdataImporter
  class TeamPhotosJob < ApplicationJob
    queue_as :default

    def perform(tenant_id:, club_data_team_id:)
      ActsAsTenant.current_tenant = Tenant.find(tenant_id)
      club_data_team = ClubDataTeam.find(club_data_team_id)

      count = { total: 0, updated: 0 }

      url = "#{Tenant.setting('clubdata_urls_team_indeling')}&teamcode=#{club_data_team.teamcode}" \
            "&client_id=#{Tenant.setting('clubdata_client_id')}"
      json = JSON.parse(RestClient.get(url))
      json.each do |data|
        next if data["foto"].blank?

        count[:total] += 1

        member = Member.find_by(full_name: data["naam"])
        next unless member

        member.photo_data = data["foto"]
        if member.changed?
          count[:updated] += 1
          member.save!
        end
      end
      # rescue StandardError => e
      #   log_error(:team_photos_import, generic_error_body(url, e))
      # end

      ClubDataLog.create level: :info,
                         source: :team_photos_import,
                         body: "#{club_data_team.teamnaam} - #{count[:total]} imported (#{count[:updated]} updated)"
    end
  end
end
