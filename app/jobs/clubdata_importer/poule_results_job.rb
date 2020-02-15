# frozen_string_literal: true

module ClubdataImporter
  class PouleResultsJob < Que::Job
    include ClubdataJob
    self.priority = 200

    def run(tenant_id:, competition_id:)
      ActsAsTenant.with_tenant(Tenant.find(tenant_id)) do
        competition = Competition.find(competition_id)

        JSON.parse(RestClient.get(url(competition))).each do |data|
          match = update_match(data, competition)
          match.set_uitslag(data["uitslag"])
          match.save!
        rescue RestClient::BadRequest => e
          handle_bad_request(:poule_results_import, competition, e)
        end
      end
    end

    def url(competition)
      "#{Tenant.setting('clubdata_urls_pouleuitslagen')}&poulecode=#{competition.poulecode}" \
      "&client_id=#{Tenant.setting('clubdata_client_id')}"
    end
  end
end
