module ClubdataImporter
  class PouleStandingJob < Que::Job
    include ClubdataJob
    self.priority = 200

    def run(tenant_id:, competition_id:)
      ActsAsTenant.with_tenant(Tenant.find(tenant_id)) do
        competition = Competition.find(competition_id)
        json = JSON.parse(RestClient.get(url(competition)))
        competition.update!(ranking: json) if json.present?
      rescue RestClient::BadRequest => e
        handle_bad_request(:poule_results_import, competition, e)
      end
    end

    def url(competition)
      "#{Tenant.setting("clubdata_urls_poulestand")}&poulecode=#{competition.poulecode}" \
      "&client_id=#{Tenant.setting("clubdata_client_id")}"
    end
  end
end
