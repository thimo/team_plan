module ClubdataImporter
  class TeamPhotosJob < Que::Job
    def run(tenant_id:, club_data_team_id:)
      ActsAsTenant.with_tenant(Tenant.find(tenant_id)) do
        club_data_team = ClubDataTeam.find(club_data_team_id)

        JSON.parse(RestClient.get(url(club_data_team))).each do |data|
          next if (foto_data = data["foto"]).blank?

          count[:total] += 1
          member = Member.find_by(full_name: data["naam"])
          next if member.blank?

          update_photo(member, foto_data)
        end

        log(club_data_team)
      end
    end

    def url(club_data_team)
      "#{Tenant.setting('clubdata_urls_team_indeling')}&teamcode=#{club_data_team.teamcode}" \
      "&client_id=#{Tenant.setting('clubdata_client_id')}"
    end

    def update_photo(member, data)
      member.photo_data = Base64.decode64(data)
      return unless member.changed?

      count[:updated] += 1
      member.save!
    end

    def count
      @count ||= { total: 0, updated: 0 }
    end

    def log(club_data_team)
      return if (updated = count[:updated]).zero?

      ClubDataLog.create level: :info,
                         source: :team_photos_import,
                         body: "#{club_data_team.teamnaam} - #{count[:total]} imported (#{updated} updated)"
    end
  end
end
