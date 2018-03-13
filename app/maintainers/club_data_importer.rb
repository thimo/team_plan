module ClubDataImporter
  def self.teams_and_competitions
    json = JSON.load(open("#{Setting['clubdata.urls.competities']}&client_id=#{Setting['clubdata.client_id']}"))
    json.each do |data|
      club_data_team = ClubDataTeam.find_or_initialize_by(teamcode: data['teamcode'])
      %w[teamnaam spelsoort geslacht teamsoort leeftijdscategorie kalespelsoort speeldag speeldagteam].each do |field|
        club_data_team.write_attribute(field, data[field])
      end
      ClubDataLog.create level: :info, source: :teams_and_competitions_import, body: "Team '#{club_data_team.teamnaam}' aangemaakt" if club_data_team.new_record?
      club_data_team.save if club_data_team.changed? || club_data_team.new_record?

      club_data_team.link_to_team

      competition = Competition.find_or_initialize_by(poulecode: data['poulecode'])
      %w[competitienaam klasse poule klassepoule competitiesoort].each do |field|
        competition.write_attribute(field, data[field])
      end
      if competition.valid?
        ClubDataLog.create level: :info, source: :teams_and_competitions_import, body: "Competitie '#{competition.competitiesoort} - #{competition.klasse}' aangemaakt voor '#{club_data_team.teamnaam}'" if competition.new_record?
        competition.save if competition.changed? || competition.new_record?

        competition.club_data_teams << club_data_team unless competition.club_data_team_ids.include?(club_data_team.id)
      end
    end

    ClubDataLog.create level: :info, source: :teams_and_competitions_import, body: "Finished"
  end

  def self.club_results
    # Regular import of all club matches
    json = JSON.load(open("#{Setting['clubdata.urls.uitslagen']}&client_id=#{Setting['clubdata.client_id']}"))
    json.each do |data|
      Match.find_by(wedstrijdcode: data['wedstrijdcode'])&.update_uitslag(data['uitslag'])
    end

    ClubDataLog.create level: :info, source: :club_results_import, body: "Finished"
  end

  def self.poules
    poule_standings
    poule_matches
    poule_results
  end

  def self.poule_standings
    Competition.active.each do |competition|
      begin
        # Fetch ranking
        json = JSON.load(open("#{Setting['clubdata.urls.poulestand']}&poulecode=#{competition.poulecode}&client_id=#{Setting['clubdata.client_id']}"))
        if json.present?
          competition.ranking = json
          competition.save if competition.changed?
        end

      rescue OpenURI::HTTPError
        # TODO handle error, maybe de-activate competition
      end
    end

    ClubDataLog.create level: :info, source: :poule_standings_import, body: "Finished"
  end

  def self.poule_matches
    Competition.active.each do |competition|
      begin
        imported_wedstrijdnummers = []

        # Fetch upcoming matches
        json = JSON.load(open("#{Setting['clubdata.urls.poule-programma']}&poulecode=#{competition.poulecode}&client_id=#{Setting['clubdata.client_id']}"))
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
        # TODO handle error, maybe de-activate competition
      end
    end

    ClubDataLog.create level: :info, source: :poule_matches_import, body: "Finished"
  end

  def self.poule_results
    Competition.active.each do |competition|
      begin
        json = JSON.load(open("#{Setting['clubdata.urls.pouleuitslagen']}&poulecode=#{competition.poulecode}&client_id=#{Setting['clubdata.client_id']}"))
        json.each do |data|
          update_match(data, competition).update_uitslag(data['uitslag'])
        end
      rescue OpenURI::HTTPError
        # TODO handle error, maybe de-activate competition
      end
    end

    ClubDataLog.create level: :info, source: :poule_results_import, body: "Finished"
  end

  def self.team_photos
    ClubDataTeam.active.each do |club_data_team|
      json = JSON.load(open("#{Setting['clubdata.urls.team-indeling']}&teamcode=#{club_data_team.teamcode}&client_id=#{Setting['clubdata.client_id']}"))
      json.each do |data|
        if data['foto'].present?
          member = Member.find_by(full_name: data['naam'])
          if member
            member.photo_data = data['foto']
            member.save if member.changed?
          end
        end
      end
    end

    ClubDataLog.create level: :info, source: :team_photos_import, body: "Finished"
  end

  def self.add_address(match)
    if match.adres.blank?
      json = JSON.load(open("#{Setting['clubdata.urls.wedstrijd-accommodatie']}?wedstrijdcode=#{match.wedstrijdcode}&client_id=#{Setting['clubdata.client_id']}"))
      if json['wedstrijd'].present?
        wedstrijd = json['wedstrijd']

        match.write_attribute('adres', wedstrijd['adres'])
        if (zip = wedstrijd['plaats'].split.first)&.match(/\d{4}[a-zA-Z]{2}/)
          match.write_attribute('postcode', zip)
        end
        match.write_attribute('telefoonnummer', wedstrijd['telefoonnummer'])
        match.write_attribute('route', wedstrijd['route'])
        match.save if match.changed?
      end
    end
  rescue OpenURI::HTTPError
    # Not all match codes return a valid response, ignore errors
  end

  def self.afgelastingen
    # Regular import of all club matches
    json = JSON.load(open("#{Setting['clubdata.urls.afgelastingen']}&client_id=#{Setting['clubdata.client_id']}"))
    cancelled_matches = []
    json.each do |data|
      if (match = Match.find_by(wedstrijdcode: data['wedstrijdcode'])).present?
        match.update(
          afgelast: true,
          afgelast_status: data['status']
        )

        cancelled_matches << data['wedstrijdcode']
      end
    end

    Match.afgelast.each do |match|
      unless cancelled_matches.include? match.wedstrijdcode
        match.update(
          afgelast: false,
          afgelast_status: ''
        )
      end
    end

    ClubDataLog.create level: :info, source: :afgelastingen_import, body: "Finished"
  end

  private

    def self.add_team_to_match(match, teamcode)
      club_data_team = ClubDataTeam.find_by(teamcode: teamcode)
      if club_data_team&.team && !match.team_ids.include?(club_data_team.team.id)
        match.teams << club_data_team.team
      end
    end

    def self.update_match(data, competition)
      match = Match.find_or_initialize_by(wedstrijdcode: data['wedstrijdcode'])
      %w[wedstrijddatum wedstrijdnummer thuisteam uitteam thuisteamclubrelatiecode uitteamclubrelatiecode accommodatie plaats wedstrijd thuisteamid uitteamid eigenteam].each do |field|
        match.write_attribute(field, data[field]) if data.include?(field)
      end
      match.competition = competition
      match.save if match.changed? || match.new_record?
      match
    end

end
