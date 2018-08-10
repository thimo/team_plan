# frozen_string_literal: true

module ClubDataImporter
  def self.teams_and_competitions
    return if Season.active_season_for_today.nil?

    url = "#{Setting['clubdata.urls.competities']}&client_id=#{Setting['clubdata.client_id']}"
    json = JSON.parse(RestClient.get(url))
    json.each do |data|
      club_data_team = ClubDataTeam.find_or_initialize_by(teamcode: data["teamcode"])
      %w[teamnaam spelsoort geslacht teamsoort leeftijdscategorie kalespelsoort speeldag speeldagteam].each do |field|
        club_data_team.write_attribute(field, data[field])
      end
      if club_data_team.new_record?
        ClubDataLog.create level: :info,
                           source: :teams_and_competitions_import,
                           body: "Team '#{club_data_team.teamnaam}' aangemaakt"
      end
      club_data_team.save if club_data_team.changed? || club_data_team.new_record?

      club_data_team.link_to_team

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
      end
      competition.save if competition.changed? || competition.new_record?
      competition.club_data_teams << club_data_team unless competition.club_data_team_ids.include?(club_data_team.id)
    end

    ClubDataLog.create level: :info, source: :teams_and_competitions_import, body: "Finished"
  end

  def self.club_results
    return if Season.active_season_for_today.nil?

    # Regular import of all club matches
    url = "#{Setting['clubdata.urls.uitslagen']}&client_id=#{Setting['clubdata.client_id']}"
    json = JSON.parse(RestClient.get(url))
    json.each do |data|
      Match.find_by(wedstrijdcode: data["wedstrijdcode"])&.update_uitslag(data["uitslag"])
    end

    ClubDataLog.create level: :info, source: :club_results_import, body: "Finished"
  end

  def self.poules
    return if Season.active_season_for_today.nil?

    poule_standings
    poule_matches
    poule_results
  end

  def self.poule_standings
    return if Season.active_season_for_today.nil?

    Competition.active.each do |competition|
      # Fetch ranking
      url = "#{Setting['clubdata.urls.poulestand']}&poulecode=#{competition.poulecode}" \
            "&client_id=#{Setting['clubdata.client_id']}"
      json = JSON.parse(RestClient.get(url))
      if json.present?
        competition.ranking = json
        competition.save if competition.changed?
      end

    rescue OpenURI::HTTPError
      ClubDataLog.create level: :error,
                         source: :poule_standings,
                         body: "Error opening/parsing #{url}"
    end

    ClubDataLog.create level: :info, source: :poule_standings_import, body: "Finished"
  end

  def self.poule_matches
    return if Season.active_season_for_today.nil?

    Competition.active.each do |competition|
      imported_wedstrijdnummers = []

      # Fetch upcoming matches
      url = "#{Setting['clubdata.urls.poule-programma']}&poulecode=#{competition.poulecode}" \
            "&client_id=#{Setting['clubdata.client_id']}"
      json = JSON.parse(RestClient.get(url))
      json.each do |data|
        match = update_match(data, competition)

        if match.eigenteam?
          add_team_to_match(match, match.thuisteamid)
          add_team_to_match(match, match.uitteamid)

          add_address(match) if match.adres.blank?
        end

        imported_wedstrijdnummers << match.wedstrijdnummer
      end

      # Cleanup matches that were not included in the import
      competition.matches.not_played.from_now.each do |match|
        match.delete unless imported_wedstrijdnummers.include? match.wedstrijdnummer
      end

    rescue OpenURI::HTTPError
      ClubDataLog.create level: :error,
                         source: :poule_matches,
                         body: "Error opening/parsing #{url}"
    end

    ClubDataLog.create level: :info, source: :poule_matches_import, body: "Finished"
  end

  def self.poule_results
    return if Season.active_season_for_today.nil?

    Competition.active.each do |competition|
      url = "#{Setting['clubdata.urls.pouleuitslagen']}&poulecode=#{competition.poulecode}" \
            "&client_id=#{Setting['clubdata.client_id']}"
      json = JSON.parse(RestClient.get(url))
      json.each do |data|
        update_match(data, competition).update_uitslag(data["uitslag"])
      end
    rescue OpenURI::HTTPError
      ClubDataLog.create level: :error,
                         source: :poule_results,
                         body: "Error opening/parsing #{url}"
    end

    ClubDataLog.create level: :info, source: :poule_results_import, body: "Finished"
  end

  def self.team_photos
    return if Season.active_season_for_today.nil?

    ClubDataTeam.active.each do |club_data_team|
      url = "#{Setting['clubdata.urls.team-indeling']}&teamcode=#{club_data_team.teamcode}" \
            "&client_id=#{Setting['clubdata.client_id']}"
      json = JSON.parse(RestClient.get(url))
      json.each do |data|
        next if data["foto"].blank?

        member = Member.find_by(full_name: data["naam"])
        if member
          member.photo_data = data["foto"]
          member.save if member.changed?
        end
      end
    end

    ClubDataLog.create level: :info, source: :team_photos_import, body: "Finished"
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
  rescue OpenURI::HTTPError
    ClubDataLog.create level: :error,
                       source: :add_address,
                       body: "Error opening/parsing #{url}"
  end

  def self.afgelastingen
    return if Season.active_season_for_today.nil?

    # Regular import of all club matches
    url = "#{Setting['clubdata.urls.afgelastingen']}&client_id=#{Setting['clubdata.client_id']}"
    json = JSON.parse(RestClient.get(url))
    cancelled_matches = []
    json.each do |data|
      next if (match = Match.find_by(wedstrijdcode: data["wedstrijdcode"])).blank?

      match.update(
        afgelast: true,
        afgelast_status: data["status"]
      )

      cancelled_matches << data["wedstrijdcode"]
    end

    Match.afgelast.each do |match|
      next if cancelled_matches.include? match.wedstrijdcode

      match.update(
        afgelast: false,
        afgelast_status: ""
      )
    end

    ClubDataLog.create level: :info, source: :afgelastingen_import, body: "Finished"
  end

  def self.add_team_to_match(match, teamcode)
    club_data_team = ClubDataTeam.find_by(teamcode: teamcode)

    match.teams << club_data_team.team if club_data_team&.team && !match.team_ids.include?(club_data_team.team.id)
  end

  def self.update_match(data, competition)
    match = Match.find_or_initialize_by(wedstrijdcode: data["wedstrijdcode"])
    %w[wedstrijddatum wedstrijdnummer thuisteam uitteam thuisteamclubrelatiecode uitteamclubrelatiecode accommodatie
       plaats wedstrijd thuisteamid uitteamid eigenteam].each do |field|
      match.write_attribute(field, data[field]) if data.include?(field)
    end
    match.competition = competition
    match.save if match.changed? || match.new_record?
    match
  end
end
