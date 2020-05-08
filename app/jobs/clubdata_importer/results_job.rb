module ClubdataImporter
  class ResultsJob < Que::Job
    self.priority = 50

    def run(tenant_id:)
      ActsAsTenant.with_tenant(Tenant.find(tenant_id)) do
        count = {total: 0, updated: 0}

        # Regular import of all club matches
        JSON.parse(RestClient.get(url)).each do |data|
          count[:total] += 1
          match = Match.find_by(wedstrijdcode: data["wedstrijdcode"])
          next if match.nil?

          match.set_uitslag(data["uitslag"])
          if match.changed?
            match.save!
            count[:updated] += 1
          end
        end

        ClubDataLog.create level: :info,
                           source: :club_results_import,
                           body: "#{count[:total]} imported (#{count[:updated]} updated)"
        # rescue StandardError => e
        #   log_error(:club_results_import, generic_error_body(url, e))
      end
    end

    def url
      "#{Tenant.setting("clubdata_urls_uitslagen")}&client_id=#{Tenant.setting("clubdata_client_id")}"
    end
  end
end
