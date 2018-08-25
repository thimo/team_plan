# frozen_string_literal: true

module ClubDataImporter
  def self.teams_and_competitions
    return if Season.active_season_for_today.nil?

    team_count = { total: 0, created: 0, updated: 0 }
    competition_count = { total: 0, created: 0, updated: 0 }

    url = "#{Setting['clubdata.urls.competities']}&client_id=#{Setting['clubdata.client_id']}"
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
  end

  def self.club_results
    return if Season.active_season_for_today.nil?

    count = { total: 0, updated: 0 }

    # Regular import of all club matches
    url = "#{Setting['clubdata.urls.uitslagen']}&client_id=#{Setting['clubdata.client_id']}"
    json = JSON.parse(RestClient.get(url))
    json.each do |data|
      count[:total] += 1
      match = Match.find_by(wedstrijdcode: data["wedstrijdcode"])
      match.set_uitslag(data["uitslag"])
      if match.changed?
        match.save
        count[:updated] += 1
      end
    end

    ClubDataLog.create level: :info,
                       source: :club_results_import,
                       body: "#{count[:total]} imported (#{count[:updated]} updated)"
  end

  def self.poules
    return if Season.active_season_for_today.nil?

    poule_standings
    poule_matches
    poule_results
  end

  def self.poule_standings
    return if Season.active_season_for_today.nil?

    count = { total: 0, updated: 0 }

    Season.active_season_for_today.competitions.active.each do |competition|
      # Fetch ranking
      url = "#{Setting['clubdata.urls.poulestand']}&poulecode=#{competition.poulecode}" \
            "&client_id=#{Setting['clubdata.client_id']}"
      json = JSON.parse(RestClient.get(url))
      if json.present?
        count[:total] += 1

        competition.ranking = json
        if competition.changed?
          count[:updated] += 1
          competition.save
        end
      end

    rescue => e
      ClubDataLog.create level: :error,
                         source: :poule_standings,
                         body: "Error opening/parsing #{url}\n\n#{e.backtrace.join("\n")}"
    end

    ClubDataLog.create level: :info,
                       source: :poule_standings_import,
                       body: "#{count[:total]} imported (#{count[:updated]} updated)"
  end

  def self.poule_matches
    return if Season.active_season_for_today.nil?

    count = { total: 0, created: 0, updated: 0, deleted: 0 }

    Season.active_season_for_today.competitions.active.each do |competition|
      imported_wedstrijdnummers = []

      # Fetch upcoming matches
      url = "#{Setting['clubdata.urls.poule-programma']}&poulecode=#{competition.poulecode}" \
            "&client_id=#{Setting['clubdata.client_id']}"
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

    rescue => e
      ClubDataLog.create level: :error,
                         source: :poule_matches,
                         body: "Error opening/parsing #{url}\n\n#{e.backtrace.join("\n")}"
    end

    ClubDataLog.create level: :info,
                       source: :poule_matches_import,
                       body: "#{count[:total]} imported (#{count[:created]} created, \
                                                         #{count[:updated]} updated, \
                                                         #{count[:deleted]} deleted)"
  end

  def self.poule_results
    return if Season.active_season_for_today.nil?

    count = { total: 0, created: 0, updated: 0 }

    Season.active_season_for_today.competitions.active.each do |competition|
      url = "#{Setting['clubdata.urls.pouleuitslagen']}&poulecode=#{competition.poulecode}" \
            "&client_id=#{Setting['clubdata.client_id']}"
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
    rescue => e
      ClubDataLog.create level: :error,
                         source: :poule_results,
                         body: "Error opening/parsing #{url}\n\n#{e.backtrace.join("\n")}"
    end

    ClubDataLog.create level: :info,
                       source: :poule_results_import,
                       body: "#{count[:total]} imported (#{count[:created]} created, \
                                                         #{count[:updated]} updated)"
  end

  def self.team_photos
    return if Season.active_season_for_today.nil?

    count = { total: 0, updated: 0 }

    Season.active_season_for_today.club_data_teams.active.each do |club_data_team|
      url = "#{Setting['clubdata.urls.team-indeling']}&teamcode=#{club_data_team.teamcode}" \
            "&client_id=#{Setting['clubdata.client_id']}"
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
    rescue => e
      ClubDataLog.create level: :error,
                         source: :team_photos_import,
                         body: "Error opening/parsing #{url}\n\n#{e.backtrace.join("\n")}"
    end

    ClubDataLog.create level: :info,
                       source: :team_photos_import,
                       body: "#{count[:total]} imported (#{count[:updated]} updated)"
  end

  def self.add_address(match)
    return if match.adres.present?

    url = "#{Setting['clubdata.urls.wedstrijd-accommodatie']}?wedstrijdcode=#{match.wedstrijdcode}" \
          "&client_id=#{Setting['clubdata.client_id']}"
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
  rescue => e
    ClubDataLog.create level: :error,
                       source: :add_address,
                       body: "Error opening/parsing #{url}\n\n#{e.backtrace.join("\n")}"
  end

  def self.afgelastingen
    return if Season.active_season_for_today.nil?

    count = { total: 0, created: 0, deleted: 0 }

    # Regular import of all club matches
    url = "#{Setting['clubdata.urls.afgelastingen']}&client_id=#{Setting['clubdata.client_id']}"
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
  end

  def self.add_team_to_match(match, teamcode)
    club_data_team = ClubDataTeam.find_by(teamcode: teamcode, season: Season.active_season_for_today)
    return if club_data_team.nil?

    club_data_team.teams.each do |team|
      match.teams << team unless match.team_ids.include?(team.id)
    end
  end

  def self.update_match(data, competition)
    match = Match.find_or_initialize_by(wedstrijdcode: data["wedstrijdcode"])
    %w[wedstrijddatum wedstrijdnummer thuisteam uitteam thuisteamclubrelatiecode uitteamclubrelatiecode accommodatie
       plaats wedstrijd thuisteamid uitteamid eigenteam].each do |field|
      match.write_attribute(field, data[field]) if data.include?(field)
    end
    match.competition = competition
    match
  end
end
