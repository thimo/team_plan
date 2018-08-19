# frozen_string_literal: true

module MatchesHelper
  def team_for(wedstrijddatum, teamid)
    Season.for_date(wedstrijddatum).first.teams.by_teamcode(teamid).first
  end
end
