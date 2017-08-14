module MatchesHelper
  def match_title(match)
    teams = ["#{Setting['club.name_short']} #{match.team.name}", match.opponent]
    if match.location_home?
      teams * ' - '
    else
      teams.reverse * ' - '
    end
  end
end
