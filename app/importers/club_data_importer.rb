module ClubDataImporter
  def teams_and_competitions
    json = JSON.load(open("#{Setting['clubdata.urls.competities']}&client_id=#{Setting['clubdata.client_id']}"))
    json.each do |data|
      club_data_team = ClubDataTeam.find_or_initialize_by(teamcode: data['teamcode'])
      %w[teamnaam spelsoort geslacht teamsoort leeftijdscategorie kalespelsoort speeldag speeldagteam].each do |field|
        club_data_team.write_attribute(field, data[field])
      end
      club_data_team.save

      club_data_team.link_to_team

      competition = ClubDataCompetition.find_or_initialize_by(poulecode: data['poulecode'])
      competition.club_data_team = club_data_team
      %w[competitienaam klasse poule klassepoule competitiesoort].each do |field|
        competition.write_attribute(field, data[field])
      end
      competition.save
    end
  end

  def results
    json = JSON.load(open("#{Setting['clubdata.urls.uitslagen']}&client_id=#{Setting['clubdata.client_id']}"))
    json.each do |data|
      club_data_match = ClubDataMatch.find_by(wedstrijdcode: data['wedstrijdcode'])

      if club_data_match.present?
        club_data_match.update(uitslag: data["uitslag"])
      end
    end
  end

  def poule_standing_and_matches
    ClubDataCompetition.active.each do |competition|
      # Fetch ranking
      json = JSON.load(open("#{Setting['clubdata.urls.poulestand']}&poulecode=#{competition.poulecode}&client_id=#{Setting['clubdata.client_id']}"))
      if json.present?
        competition.ranking = json
        competition.save
      end

      imported_wedstrijdnummers = []

      # Fetch upcoming matches
      json = JSON.load(open("#{Setting['clubdata.urls.poule-programma']}&poulecode=#{competition.poulecode}&client_id=#{Setting['clubdata.client_id']}"))
      json.each do |data|
        club_data_match = ClubDataMatch.find_or_initialize_by(wedstrijdcode: data['wedstrijdcode'])
        %w[wedstrijddatum wedstrijdnummer thuisteam uitteam thuisteamclubrelatiecode uitteamclubrelatiecode accommodatie plaats wedstrijd thuisteamid uitteamid].each do |field|
          club_data_match.write_attribute(field, data[field])
        end
        club_data_match.club_data_competition = competition
        if data['eigenteam'] == 'true'
          club_data_team = ClubDataTeam.find_by(teamcode: data['thuisteamid'])
          club_data_team ||= ClubDataTeam.find_by(teamcode: data['uitteamid'])
          club_data_match.team = club_data_team&.team
        end
        club_data_match.save

        imported_wedstrijdnummers << club_data_match.wedstrijdnummer
      end

      # Cleanup matches that were not included in the import
      competition.club_data_matches.not_played.from_now.each do |match|
        match.delete unless imported_wedstrijdnummers.include? match.wedstrijdnummer
      end
    end
  end

  def team_photos
    ClubDataTeam.active.each do |club_data_team|
      team = club_data_team.team
      json = JSON.load(open("#{Setting['clubdata.urls.team-indeling']}&teamcode=#{club_data_team.teamcode}&client_id=#{Setting['clubdata.client_id']}"))
      json.each do |data|
        # Zoek team member op a.h.v. naam (achternaam, voornaam tussenvoegsels)
        # Misschien query op achternaam (links van ','), daarna filter op voornaam + tussenvoegsels
        # Decodeer base64 naar image en koppel aan member
      end
    end
  end
end
