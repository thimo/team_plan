module ClubDataImporter
  def self.teams_and_competitions
    json = JSON.load(open("#{Setting['clubdata.urls.competities']}&client_id=#{Setting['clubdata.client_id']}"))
    json.each do |data|
      club_data_team = ClubDataTeam.find_or_initialize_by(teamcode: data['teamcode'])
      %w[teamnaam spelsoort geslacht teamsoort leeftijdscategorie kalespelsoort speeldag speeldagteam].each do |field|
        club_data_team.write_attribute(field, data[field])
      end
      club_data_team.save

      club_data_team.link_to_team

      competition = ClubDataCompetition.find_or_initialize_by(poulecode: data['poulecode'])
      %w[competitienaam klasse poule klassepoule competitiesoort].each do |field|
        competition.write_attribute(field, data[field])
      end
      competition.save

      competition.club_data_teams << club_data_team unless competition.club_data_team_ids.include?(club_data_team.id)
    end
  end

  def self.club_results
    # Regular import of all club matches
    json = JSON.load(open("#{Setting['clubdata.urls.uitslagen']}&client_id=#{Setting['clubdata.client_id']}"))
    json.each do |data|
      ClubDataMatch.find_by(wedstrijdcode: data['wedstrijdcode'])&.update_uitslag(data['uitslag'])
    end
  end

  def self.poule_standings
    ClubDataCompetition.active.each do |competition|
      # Fetch ranking
      json = JSON.load(open("#{Setting['clubdata.urls.poulestand']}&poulecode=#{competition.poulecode}&client_id=#{Setting['clubdata.client_id']}"))
      if json.present?
        competition.ranking = json
        competition.save
      end
    end
  end

  def self.poule_matches
    ClubDataCompetition.active.each do |competition|
      imported_wedstrijdnummers = []

      # Fetch upcoming matches
      json = JSON.load(open("#{Setting['clubdata.urls.poule-programma']}&poulecode=#{competition.poulecode}&client_id=#{Setting['clubdata.client_id']}"))
      json.each do |data|
        club_data_match = ClubDataMatch.find_or_initialize_by(wedstrijdcode: data['wedstrijdcode'])
        %w[wedstrijddatum wedstrijdnummer thuisteam uitteam thuisteamclubrelatiecode uitteamclubrelatiecode accommodatie plaats wedstrijd thuisteamid uitteamid eigenteam].each do |field|
          club_data_match.write_attribute(field, data[field])
        end
        club_data_match.club_data_competition = competition
        club_data_match.save

        if club_data_match.eigenteam?
          add_team_to_match(club_data_match, club_data_match.thuisteamid)
          add_team_to_match(club_data_match, club_data_match.uitteamid)

          add_address(club_data_match) if club_data_match.adres.blank?
        end


        imported_wedstrijdnummers << club_data_match.wedstrijdnummer
      end

      # Cleanup matches that were not included in the import
      competition.club_data_matches.not_played.from_now.each do |match|
        match.delete unless imported_wedstrijdnummers.include? match.wedstrijdnummer
      end
    end
  end

  def self.poule_results
    ClubDataCompetition.active.each do |competition|
      json = JSON.load(open("#{Setting['clubdata.urls.pouleuitslagen']}&poulecode=#{competition.poulecode}&client_id=#{Setting['clubdata.client_id']}"))
      json.each do |data|
        ClubDataMatch.find_by(wedstrijdcode: data['wedstrijdcode'])&.update_uitslag(data['uitslag'])
      end
    end
  end

  def self.team_photos
    ClubDataTeam.active.each do |club_data_team|
      json = JSON.load(open("#{Setting['clubdata.urls.team-indeling']}&teamcode=#{club_data_team.teamcode}&client_id=#{Setting['clubdata.client_id']}"))
      json.each do |data|
        if data['foto'].present?
          member = Member.find_by(full_name: data['naam'])
          if member
            member.photo_data = data['foto']
            member.save
          end
        end
      end
    end
  end

  def self.add_address(match)
    if match.adres.blank?
      json = JSON.load(open("#{Setting['clubdata.urls.wedstrijd-accommodatie']}?wedstrijdcode=#{match.wedstrijdcode}&client_id=#{Setting['clubdata.client_id']}"))
      if json['wedstrijd'].present?
        wedstrijd = json['wedstrijd']

        match.write_attribute('adres', wedstrijd['adres'])
        if (zip = wedstrijd['plaats'].split.first).match(/\d{4}[a-zA-Z]{2}/)
          match.write_attribute('postcode', zip)
        end
        match.write_attribute('telefoonnummer', wedstrijd['telefoonnummer'])
        match.write_attribute('route', wedstrijd['route'])
        match.save
      end
    end
  rescue OpenURI::HTTPError
    # Not all match codes return a valid response, ignore errors
  end

  private

    def self.add_team_to_match(match, teamcode)
      club_data_team = ClubDataTeam.find_by(teamcode: teamcode)
      if club_data_team&.team && !match.team_ids.include?(club_data_team.team.id)
        match.teams << club_data_team.team
      end
    end
end
