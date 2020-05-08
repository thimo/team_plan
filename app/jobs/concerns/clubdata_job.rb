module ClubdataJob
  extend ActiveSupport::Concern

  included do
    private

    def handle_bad_request(source, competition, error)
      if JSON.parse(error.response.body).dig("error", "code") == 4001 # Ongeldige poulecode
        competition.deactivate
        message = "Competition #{competition.poulecode} has been disabled after a '400' response from the server"
        log_error(source, message)
      else
        log_error(source, generic_error_body(url, error))
      end
    end

    def add_team_to_match(match, teamcode)
      club_data_team = ClubDataTeam.find_by(teamcode: teamcode, season: Season.active_season_for_today)
      return if club_data_team.nil?

      club_data_team.teams.each do |team|
        match.teams << team unless match.team_ids.include?(team.id)
      end
    end

    def update_match(data, competition)
      match = Match.find_or_initialize_by(wedstrijdcode: data["wedstrijdcode"])
      %w[wedstrijddatum wedstrijdnummer thuisteam uitteam thuisteamclubrelatiecode uitteamclubrelatiecode accommodatie
        plaats wedstrijd thuisteamid uitteamid eigenteam].each do |field|
        match.write_attribute(field, data[field]) if data.include?(field)
      end
      match.competition = competition
      match
    end

    def add_address(match)
      return if match.adres.present?

      url = "#{Tenant.setting("clubdata_urls_wedstrijd_accommodatie")}?wedstrijdcode=#{match.wedstrijdcode}" \
            "&client_id=#{Tenant.setting("clubdata_client_id")}"
      json = JSON.parse(RestClient.get(url))
      if json["wedstrijd"].present?
        wedstrijd = json["wedstrijd"]

        match.write_attribute("adres", wedstrijd["adres"])
        if (zip = wedstrijd["plaats"].split.first)&.match(/\d{4}[a-zA-Z]{2}/)
          match.write_attribute("postcode", zip)
        end
        match.write_attribute("telefoonnummer", wedstrijd["telefoonnummer"])
        match.write_attribute("route", wedstrijd["route"])
        match.save! if match.changed?
      end
    rescue => e
      log_error(:add_address, generic_error_body(url, e))
    end

    def log_error(source, body)
      ClubDataLog.create level: :error,
                         source: source,
                         body: body
    end

    def generic_error_body(url, error)
      "Error opening/parsing #{url}\n\n#{error.inspect}\n#{error.backtrace.join("\n")}"
    end
  end
end
