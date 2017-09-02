class Admin::ClubData::CompetitionsImportController < AdminController
  def new
    authorize ClubDataCompetition

    # Import URL
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

    redirect_to admin_club_data_competitions_path
  end
end

 # wedstrijddatum wedstrijdnummer thuisteam uitteam thuisteamclubrelatiecode uitteamclubrelatiecode accommodatie plaats wedstrijd thuisteamid uitteamid
