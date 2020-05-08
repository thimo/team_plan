module ClubdataImporter
  class CancelationsJob < Que::Job
    def run(tenant_id:)
      ActsAsTenant.with_tenant(Tenant.find(tenant_id)) do
        count = {total: 0, created: 0, deleted: 0}

        # Regular import of all club matches
        cancelled_matches = []
        JSON.parse(RestClient.get(url)).each do |data|
          next if (match = Match.find_by(wedstrijdcode: data["wedstrijdcode"])).blank?

          match.attributes = {afgelast: true, afgelast_status: data["status"]}
          if match.changed?
            count[:created] += 1
            match.save!
          end

          cancelled_matches << data["wedstrijdcode"]
        end

        Season.active_season_for_today.matches.afgelast.each do |match|
          next if cancelled_matches.include? match.wedstrijdcode

          match.update!(afgelast: false, afgelast_status: "")
          count[:deleted] += 1
        end

        ClubDataLog.create level: :info,
                           source: :afgelastingen_import,
                           body: "#{count[:total]} imported (#{count[:created]} created, \
                                                            #{count[:deleted]} deleted)"
      end
    end

    def url
      "#{Tenant.setting("clubdata_urls_afgelastingen")}&client_id=#{Tenant.setting("clubdata_client_id")}"
    end
  end
end
