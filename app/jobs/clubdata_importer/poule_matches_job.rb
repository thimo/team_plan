# frozen_string_literal: true

module ClubdataImporter
  class PouleMatchesJob < ApplicationJob
    include ClubdataJob
    queue_as :default

    def perform(tenant_id:, competition_id:)
      ActsAsTenant.current_tenant = Tenant.find(tenant_id)
      competition = Competition.find(competition_id)

      imported_wedstrijdnummers = []

      url = "#{Tenant.setting('clubdata_urls_poule_programma')}&poulecode=#{competition.poulecode}" \
            "&client_id=#{Tenant.setting('clubdata_client_id')}"
      json = JSON.parse(RestClient.get(url))
      json.each do |data|

        match = update_match(data, competition)
        match.save! if match.new_record? || match.changed?

        if match.eigenteam?
          add_team_to_match(match, match.thuisteamid)
          add_team_to_match(match, match.uitteamid)

          add_address(match) if match.adres.blank?
        end

        imported_wedstrijdnummers << match.wedstrijdnummer
      end

      # Cleanup matches that were not included in the import
      competition.matches.not_played.from_now.each do |match|
        unless imported_wedstrijdnummers.include? match.wedstrijdnummer
          # count[:deleted] += 1 if count.present?
          match.delete
        end
      end
    rescue RestClient::BadRequest => e
      handle_bad_request(:poule_results_import, competition, e)
    end
  end
end
