# frozen_string_literal: true

class ClubData::TeamsAndCompetitionsJob < ApplicationJob
  queue_as :default

  def perform(tenant_id:)
    ActsAsTenant.current_tenant = Tenant.find(tenant_id)

    team_count = { total: 0, created: 0, updated: 0 }
    competition_count = { total: 0, created: 0, updated: 0 }

    url = "#{Tenant.setting('clubdata_urls_competities')}&client_id=#{Tenant.setting('clubdata_client_id')}"
    json = JSON.parse(RestClient.get(url))
    json.each do |data|
      team_count[:total] += 1
      club_data_team = ClubDataTeam.find_or_initialize_by(teamcode: data["teamcode"],
                                                          season: Season.active_season_for_today)
      %w[teamnaam spelsoort geslacht teamsoort leeftijdscategorie kalespelsoort speeldag
         speeldagteam].each do |field|
        club_data_team.write_attribute(field, data[field])
      end
      if club_data_team.new_record?
        ClubDataLog.create level: :info,
                           source: :teams_and_competitions_import,
                           body: "Team '#{club_data_team.teamnaam}' aangemaakt"
        team_count[:created] += 1
        club_data_team.save!
      elsif club_data_team.changed?
        team_count[:updated] += 1
        club_data_team.save!
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
        competition.save!
        competition_count[:created] += 1

        update_poule_standing(competition)
        update_poule_matches(competition)
        update_poule_results(competition)
      elsif competition.changed?
        competition.save!
        competition_count[:updated] += 1
      end
      competition.club_data_teams << club_data_team if competition.club_data_team_ids.exclude?(club_data_team.id)
    end

    ClubDataLog.create level: :info,
                       source: :teams_and_competitions_import,
                       body: "#{team_count[:total]} teams imported \
                                (#{team_count[:created]} created, \
                                 #{team_count[:updated]} updated), \
                              #{competition_count[:total]} competitions imported \
                                (#{competition_count[:created]} created, \
                                 #{competition_count[:updated]} updated)"
    # rescue StandardError => e
    #   log_error(:teams_and_competitions_import, generic_error_body(url, e))
  end
end
