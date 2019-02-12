# frozen_string_literal: true

module ClubDataImporter
  def self.teams_and_competitions
    Tenant.active.find_each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        next if Season.active_season_for_today.nil? || Tenant.setting("clubdata.client_id").blank?

        teams_and_competitions_for_tenant
      end
    end
  end

  def self.club_results
    Tenant.active.find_each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        next if Season.active_season_for_today.nil? || Tenant.setting("clubdata.client_id").blank?

        club_results_for_tenant
      end
    end
  end

  def self.poules
    Tenant.active.find_each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        next if Season.active_season_for_today.nil? || Tenant.setting("clubdata.client_id").blank?

        poule_standings_for_tenant
        poule_matches_for_tenant
        poule_results_for_tenant
      end
    end
  end

  def self.team_photos
    Tenant.active.find_each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        next if Season.active_season_for_today.nil? || Tenant.setting("clubdata.client_id").blank?

        team_photos_for_tenant
      end
    end
  end

  def self.afgelastingen
    Tenant.active.find_each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        next if Season.active_season_for_today.nil? || Tenant.setting("clubdata.client_id").blank?

        afgelastingen_for_tenant
      end
    end
  end

  ##
  # Private class methods, should be called with tenant context
  #
  class << self
    private

    def teams_and_competitions_for_tenant
      team_count = { total: 0, created: 0, updated: 0 }
      competition_count = { total: 0, created: 0, updated: 0 }

      url = "#{Tenant.setting('clubdata.urls.competities')}&client_id=#{Tenant.setting('clubdata.client_id')}"
      json = JSON.parse(RestClient.get(url))
      json.each do |data|
        team_count[:total] += 1
        club_data_team = ClubDataTeam.find_or_initialize_by(teamcode: data["teamcode"],
                                                            season: Season.active_season_for_today)
        %w[teamnaam spelsoort geslacht teamsoort leeftijdscategorie kalespelsoort speeldag speeldagteam].each do |field|
          club_data_team.write_attribute(field, data[field])
        end
        if club_data_team.new_record?
          ClubDataLog.create level: :info,
                             source: :teams_and_competitions_import,
                             body: "Team '#{club_data_team.teamnaam}' aangemaakt"
          team_count[:created] += 1
          club_data_team.save
        elsif club_data_team.changed?
          team_count[:updated] += 1
          club_data_team.save
        end

        club_data_team.link_to_team

        competition_count[:total] += 1
        competition = Competition.find_or_initialize_by(poulecode: data["poulecode"])
        %w[competitienaam klasse poule klassepoule competitiesoort].each do |field|
          competition.write_attribute(field, data[field])
        end

        next unless competition.valid?

        if competition.new_record?
          ClubDataLog.create level: :info,
                             source: :teams_and_competitions_import,
                             body: "Competitie '#{competition.competitiesoort} - #{competition.klasse}' aangemaakt " \
                                    "voor '#{club_data_team.teamnaam}'"
          competition.save
          competition_count[:created] += 1
        elsif competition.changed?
          competition.save
          competition_count[:updated] += 1
        end
        competition.club_data_teams << club_data_team unless competition.club_data_team_ids.include?(club_data_team.id)
      end

      ClubDataLog.create level: :info,
                         source: :teams_and_competitions_import,
                         body: "#{team_count[:total]} teams imported \
                                  (#{team_count[:created]} created, \
                                   #{team_count[:updated]} updated), \
                                #{competition_count[:total]} competitions imported \
                                  (#{competition_count[:created]} created, \
                                   #{competition_count[:updated]} updated)"
    rescue StandardError => e
      log_error(:teams_and_competitions_import, url, e)
    end

    def club_results_for_tenant
      count = { total: 0, updated: 0 }

      # Regular import of all club matches
      url = "#{Tenant.setting('clubdata.urls.uitslagen')}&client_id=#{Tenant.setting('clubdata.client_id')}"
      json = JSON.parse(RestClient.get(url))
      json.each do |data|
        count[:total] += 1
        match = Match.find_by(wedstrijdcode: data["wedstrijdcode"])
        next if match.nil?

        match.set_uitslag(data["uitslag"])
        if match.changed?
          match.save
          count[:updated] += 1
        end
      end

      ClubDataLog.create level: :info,
                         source: :club_results_import,
                         body: "#{count[:total]} imported (#{count[:updated]} updated)"
    rescue StandardError => e
      log_error(:club_results_import, url, e)
    end

    def poule_standings_for_tenant
      count = { total: 0, updated: 0 }

      Season.active_season_for_today.competitions.active.each do |competition|
        # Fetch ranking
        url = "#{Tenant.setting('clubdata.urls.poulestand')}&poulecode=#{competition.poulecode}" \
              "&client_id=#{Tenant.setting('clubdata.client_id')}"
        json = JSON.parse(RestClient.get(url))
        if json.present?
          count[:total] += 1

          competition.ranking = json
          if competition.changed?
            count[:updated] += 1
            competition.save
          end
        end

      rescue StandardError => e
        log_error(:poule_standings_import, url, e)
      end

      ClubDataLog.create level: :info,
                         source: :poule_standings_import,
                         body: "#{count[:total]} imported (#{count[:updated]} updated)"
    end

    def poule_matches_for_tenant
      count = { total: 0, created: 0, updated: 0, deleted: 0 }

      Season.active_season_for_today.competitions.active.each do |competition|
        imported_wedstrijdnummers = []

        # Fetch upcoming matches
        url = "#{Tenant.setting('clubdata.urls.poule-programma')}&poulecode=#{competition.poulecode}" \
              "&client_id=#{Tenant.setting('clubdata.client_id')}"
        json = JSON.parse(RestClient.get(url))
        json.each do |data|
          count[:total] += 1

          match = update_match(data, competition)

          if match.new_record?
            count[:created] += 1
            match.save
          elsif match.changed?
            count[:updated] += 1
            match.save
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
            count[:deleted] += 1
            match.delete
          end
        end

      rescue StandardError => e
        log_error(:poule_matches_import, url, e)
      end

      ClubDataLog.create level: :info,
                         source: :poule_matches_import,
                         body: "#{count[:total]} imported (#{count[:created]} created, \
                                                           #{count[:updated]} updated, \
                                                           #{count[:deleted]} deleted)"
    end

    def poule_results_for_tenant
      count = { total: 0, created: 0, updated: 0 }

      Season.active_season_for_today.competitions.active.each do |competition|
        url = "#{Tenant.setting('clubdata.urls.pouleuitslagen')}&poulecode=#{competition.poulecode}" \
              "&client_id=#{Tenant.setting('clubdata.client_id')}"
        json = JSON.parse(RestClient.get(url))
        json.each do |data|
          count[:total] += 1
          match = update_match(data, competition)
          match.set_uitslag(data["uitslag"])

          if match.new_record?
            count[:created] += 1
            match.save
          elsif match.changed?
            count[:updated] += 1
            match.save
          end
        end
      rescue StandardError => e
        log_error(:poule_results_import, url, e)
      end

      ClubDataLog.create level: :info,
                         source: :poule_results_import,
                         body: "#{count[:total]} imported (#{count[:created]} created, \
                                                           #{count[:updated]} updated)"
    end

    def afgelastingen_for_tenant
      count = { total: 0, created: 0, deleted: 0 }

      # Regular import of all club matches
      url = "#{Tenant.setting('clubdata.urls.afgelastingen')}&client_id=#{Tenant.setting('clubdata.client_id')}"
      json = JSON.parse(RestClient.get(url))
      cancelled_matches = []
      json.each do |data|
        next if (match = Match.find_by(wedstrijdcode: data["wedstrijdcode"])).blank?

        match.attributes = { afgelast: true, afgelast_status: data["status"] }
        if match.changed?
          count[:created] += 1
          match.save
        end

        cancelled_matches << data["wedstrijdcode"]
      end

      Season.active_season_for_today.matches.afgelast.each do |match|
        next if cancelled_matches.include? match.wedstrijdcode

        match.update(
          afgelast: false,
          afgelast_status: ""
        )
        count[:deleted] += 1
      end

      ClubDataLog.create level: :info,
                         source: :afgelastingen_import,
                         body: "#{count[:total]} imported (#{count[:created]} created, \
                                                           #{count[:deleted]} deleted)"
    rescue StandardError => e
      log_error(:teams_and_competitions_import, url, e)
    end

    def team_photos_for_tenant
      count = { total: 0, updated: 0 }

      Season.active_season_for_today.club_data_teams.active.each do |club_data_team|
        url = "#{Tenant.setting('clubdata.urls.team-indeling')}&teamcode=#{club_data_team.teamcode}" \
              "&client_id=#{Tenant.setting('clubdata.client_id')}"
        json = JSON.parse(RestClient.get(url))
        json.each do |data|
          next if data["foto"].blank?

          count[:total] += 1

          member = Member.find_by(full_name: data["naam"])
          next unless member
          member.photo_data = data["foto"]
          if member.changed?
            count[:updated] += 1
            member.save
          end
        end
      rescue StandardError => e
        log_error(:team_photos_import, url, e)
      end

      ClubDataLog.create level: :info,
                         source: :team_photos_import,
                         body: "#{count[:total]} imported (#{count[:updated]} updated)"
    end

    def add_address(match)
      return if match.adres.present?

      url = "#{Tenant.setting('clubdata.urls.wedstrijd-accommodatie')}?wedstrijdcode=#{match.wedstrijdcode}" \
            "&client_id=#{Tenant.setting('clubdata.client_id')}"
      json = JSON.parse(RestClient.get(url))
      if json["wedstrijd"].present?
        wedstrijd = json["wedstrijd"]

        match.write_attribute("adres", wedstrijd["adres"])
        if (zip = wedstrijd["plaats"].split.first)&.match(/\d{4}[a-zA-Z]{2}/)
          match.write_attribute("postcode", zip)
        end
        match.write_attribute("telefoonnummer", wedstrijd["telefoonnummer"])
        match.write_attribute("route", wedstrijd["route"])
        match.save if match.changed?
      end
    rescue StandardError => e
      log_error(:add_address, url, e)
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

    def log_error(source, url, error)
      body = "Error opening/parsing #{url}\n\n#{error.message}\n#{error.backtrace.join("\n")}"
      ClubDataLog.create level: :error,
                         source: source,
                         body: body
    end
  end
end
