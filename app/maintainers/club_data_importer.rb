# frozen_string_literal: true

module ClubDataImporter
  def self.teams_and_competitions
    Tenant.active.find_each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        next if skip_update?

        ClubData::TeamsAndCompetitionsJob.perform_later(tenant_id: tenant.id)
      end
    end
  end

  def self.poules
    Tenant.active.find_each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        next if skip_update?

        poule_standings_for_tenant
        poule_matches_for_tenant
        poule_results_for_tenant
      end
    end
  end

  def self.team_photos
    Tenant.active.find_each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        next if skip_update?

        Season.active_season_for_today.club_data_teams.active.each do |club_data_team|
          ClubData::TeamPhotosJob.perform_later(tenant_id: tenant.id, club_data_team_id: club_data_team.id)
        end
      end
    end
  end

  ##
  # Private class methods, should be called with tenant context
  #
  class << self
    private

      def poule_standings_for_tenant
        count = { total: 0, updated: 0 }

        Season.active_season_for_today.competitions.active.each do |competition|
          update_poule_standing(competition, count)
        end

        ClubDataLog.create level: :info,
                           source: :poule_standings_import,
                           body: "#{count[:total]} imported (#{count[:updated]} updated)"
      end

      def update_poule_standing(competition, count = nil)
        # Fetch ranking
        url = "#{Tenant.setting('clubdata_urls_poulestand')}&poulecode=#{competition.poulecode}" \
              "&client_id=#{Tenant.setting('clubdata_client_id')}"
        json = JSON.parse(RestClient.get(url))
        if json.present?
          count[:total] += 1 if count.present?

          competition.ranking = json
          if competition.changed?
            count[:updated] += 1 if count.present?
            competition.save!
          end
        end
      rescue RestClient::BadRequest => e
        handle_bad_request(:poule_results_import, competition, e)
      rescue StandardError => e
        log_error(:poule_standings_import, generic_error_body(url, e))
      end

      def poule_matches_for_tenant
        count = { total: 0, created: 0, updated: 0, deleted: 0 }

        Season.active_season_for_today.competitions.active.each do |competition|
          update_poule_matches(competition, count)
        end

        ClubDataLog.create level: :info,
                           source: :poule_matches_import,
                           body: "#{count[:total]} imported (#{count[:created]} created, \
                                                             #{count[:updated]} updated, \
                                                             #{count[:deleted]} deleted)"
      end

      def update_poule_matches(competition, count = nil)
        imported_wedstrijdnummers = []

        # Fetch upcoming matches
        url = "#{Tenant.setting('clubdata_urls_poule_programma')}&poulecode=#{competition.poulecode}" \
              "&client_id=#{Tenant.setting('clubdata_client_id')}"
        json = JSON.parse(RestClient.get(url))
        json.each do |data|
          count[:total] += 1 if count.present?

          match = update_match(data, competition)

          if match.new_record?
            count[:created] += 1 if count.present?
            match.save!
          elsif match.changed?
            count[:updated] += 1 if count.present?
            match.save!
          end

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
            count[:deleted] += 1 if count.present?
            match.delete
          end
        end
      rescue RestClient::BadRequest => e
        handle_bad_request(:poule_results_import, competition, e)
      rescue StandardError => e
        log_error(:poule_matches_import, generic_error_body(url, e))
      end

      def poule_results_for_tenant
        count = { total: 0, created: 0, updated: 0 }

        Season.active_season_for_today.competitions.active.each do |competition|
          update_poule_results(competition, count)
        end

        ClubDataLog.create level: :info,
                           source: :poule_results_import,
                           body: "#{count[:total]} imported (#{count[:created]} created, \
                                                             #{count[:updated]} updated)"
      end

      def update_poule_results(competition, count = nil)
        url = "#{Tenant.setting('clubdata_urls_pouleuitslagen')}&poulecode=#{competition.poulecode}" \
              "&client_id=#{Tenant.setting('clubdata_client_id')}"
        json = JSON.parse(RestClient.get(url))
        json.each do |data|
          count[:total] += 1 if count.present?
          match = update_match(data, competition)
          match.set_uitslag(data["uitslag"])

          if match.new_record?
            count[:created] += 1 if count.present?
            match.save!
          elsif match.changed?
            count[:updated] += 1 if count.present?
            match.save!
          end
        end
      rescue RestClient::BadRequest => e
        handle_bad_request(:poule_results_import, competition, e)
      rescue StandardError => e
        log_error(:poule_results_import, generic_error_body(url, e))
      end

      def add_address(match)
        return if match.adres.present?

        url = "#{Tenant.setting('clubdata_urls_wedstrijd_accommodatie')}?wedstrijdcode=#{match.wedstrijdcode}" \
              "&client_id=#{Tenant.setting('clubdata_client_id')}"
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
      rescue StandardError => e
        log_error(:add_address, generic_error_body(url, e))
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

      def log_error(source, body)
        ClubDataLog.create level: :error,
                           source: source,
                           body: body
      end

      def generic_error_body(url, error)
        "Error opening/parsing #{url}\n\n#{error.inspect}\n#{error.backtrace.join("\n")}"
      end

      def handle_bad_request(source, competition, error)
        if JSON.parse(error.response.body).dig("error", "code") == 4001 # Ongeldige poulecode
          competition.deactivate
          message = "Competition #{competition.poulecode} has been disabled after a '400' response from the server"
          log_error(source, message)
        else
          log_error(source, generic_error_body(url, error))
        end
      end

      def skip_update?
        Season.active_season_for_today.nil? || Tenant.setting("clubdata_client_id").blank?
      end
  end
end
